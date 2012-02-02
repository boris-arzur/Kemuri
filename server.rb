# encoding: UTF-8
#    Copyright 2008, 2009, 2010 Boris ARZUR
#
#    This file is part of Kemuri.
#
#    Kemuri is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of
#    the License, or (at your option) any later version.
#
#    Kemuri is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public
#    License along with Kemuri. If not, see http://www.gnu.org/licenses.

require 'thread'
require 'socket'
require 'yaml'
require 'zlib'
require 'net/http' # for the proxy
#require 'ruby-prof'

if RUBY_VERSION == '1.9.0'
  #print Encoding.default_external
elsif RUBY_VERSION > '1.9.0'
  Encoding.default_external="UTF-8"
  Encoding.default_internal="UTF-8"
else
  $KCODE = 'u' # pour le split //
end

def plog *t
  log t.map{|i| i.inspect}.join( "\n" )
end

$log_mx = Mutex.new
$log_bf = []

$history_mx = Mutex.new
$history_bf = []

def log( *t )
  t = t[0] if t.size == 1
  $log_mx.synchronize do $log_bf << "[@#{Time.new.to_i.to_s( 36 )}] #{t}" end
end

def to_history( t )
  $history_mx.synchronize do $history_bf << t end
end

def message( m )
  $me.message( m )
end

require './engine.rb'
require './dbs.rb'
require './static.rb'
require './kanji_table.rb'

class Server
  def initialize()
    @port = $kemuri_port || 8185
    @name = 'Kemuri'
    @listen = $kemuri_bind || '127.0.0.1'

    @listener = ::TCPServer.new( @listen, @port )
    @message_mutex = Mutex.new
    @message = false
    log( 'Running on Ruby ' + RUBY_VERSION )
    log( "Bound to #{@listen}:#{@port}." )
  end

  def handle_connection connection
    my_id = Thread.current.object_id.to_s( 36 )
    until connection.closed? do
      request = protect( 'reading' ) {
        triggered = IO.select( [connection], [], [], 5 )
        connection.recv_nonblock( 100000 ) if triggered and not connection.closed?
      }

      if request.nil?
        protect('closing') do
          log "#{my_id} : auto-close keep-alive"
          connection.close()
        end
      elsif request == ''
        #log "#{my_id} : empty stuff size=#{request.size}, keepalive packet."
        #protect('replying') { connection.puts( "Connection: close\r\n" ) }
	connection.write("\x00"*6)
        connection.flush()
	sleep(0.1)
        #connection.close()
      else
        request = protect('parsing') {request.parse()}
        log( "#{my_id} : processing : #{request.inspect}" )
        t = Time.new
        answer = protect('executing') {Servlet::execute( request )}
        log "That took #{Time.new - t} s."
        if not request.xml
          protect('add_capture') {answer += (request['capture'] ? Static::Capture : Static::Normal)}
          @message_mutex.synchronize do
            if @message
              answer = "<div style='color:red'>#{@message}</div>" + answer
              @message = false
            end
          end
        elsif request['capture']
          answer += Static::Capture
        end

        protect('replying') {connection.print( (request.xml ? answer : answer.in_skel).to_http )}
        connection.flush()
        connection.close() unless request.keep_alive
      end
    end
    log "#{my_id} out."
  end

  def start_serving
    loop do
      connection = @listener.accept
      log 'Server main loop : new connection'
      Thread.new {handle_connection( connection )}
    end
  end

  def start_flusher
    sleep_time = $sleep_time || 10
    Thread.new do
      loop do
        begin
          sleep sleep_time
          if $log_bf.size > 5
            $log_mx.synchronize do
              #FIX
              log_buf_content = ($log_bf * "\n").force_encoding('UTF-8')
              File::open( 'server.log' , 'a' ) {|f| f.puts( log_buf_content )}
              $log_bf = []
            end
          end

          if $history_bf.size > 0
            $history_mx.synchronize do
              File::open( 'history.log' , 'a' ) {|f| f.puts( $history_bf * "\n" )}
              $history_bf = []
            end
          end
        rescue Exception => e
          msg = "#{"\n".encoding+' --  '+$log_bf.inspect}#{e.inspect.escape}<br/>#{e.backtrace.map{|l| l.escape}.join( "<br/>" )}"
          message msg
        end
      end
    end
  end

  def to_url
    return "http://#{@listen}:#{@port}/" if @listen != "0.0.0.0"
    "/"
  end

  def message( m )
    m = "/!\\ #{m} /!\\"
    @message_mutex.synchronize do
      if @message
        @message += "<br/>#{m}"
      else
        @message = m
      end
    end
  end
end

class Servlet
  @@servlets = {}

  Ext = /\.sv\.rb$/

  def self.register_all
    Kemuri.files.each do |file|
      Servlet::register( file ) if file =~ Ext
    end

    @@servlets.default = ::Quatrecentquatre.new
    log( "Registered modules : " + @@servlets.keys.inspect )
  end

  def self.register( file )
    load( file )
    name = file.gsub( Ext , '' )
    @@servlets[name] = eval( name.capitalize + '.new' )
  end

  def self.execute( request )
    @@servlets[request[0]].execute( request )
  end
end

def server_start
  `rm server.log;touch server.log`
  Servlet::register_all
  $me = Server.new
  File.open( "kemuri.pid", "w" ) {|f| f.print( Process.pid )}
  $me.start_flusher
  $me.start_serving
end
