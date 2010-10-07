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
def log( t )
  $log_mx.synchronize do 
    File::open( 'server.log' , 'a' ) {|f| f.puts( "#{Time.new.to_i.to_s( 36 )} : #{t}" )}
  end
end

$history_mx = Mutex.new
def to_history( t )
  $history_mx.synchronize do 
    File::open( 'history.log' , 'a' ) {|f| f.puts( t )}
  end
end

require './engine.rb'
require './dbs.rb'
require './static.rb'
require './kanji_table.rb'

class Server
  def initialize()
    @port = $kemuri_port || 8185
    @name = 'Kemuri'
    @listen = '127.0.0.1'

    @listener = ::TCPServer.new( @listen, @port )
    log( 'Running on Ruby ' + RUBY_VERSION )
  end

  def handle_connection connection
    until connection.closed? do
      request = protect( 'reading' ) { 
        triggered = IO.select( [connection], [], [], 5 )
        connection.recv_nonblock( 100000 ) if triggered and not connection.closed?
      }
     
      if request.nil?
        protect('closing') do
          log 'Server dedicated thread : auto-close keep-alive'
          connection.close()
        end
      elsif request == ''
        log 'Server dedicated thread : got empty request'
        sleep 0.1
      else
        request = protect('parsing') {request.parse()}
        log( request.inspect )
        answer = protect('executing') {Servlet::execute( request )}
        if not request.xml
          protect('add_capture') {answer += (request['capture'] ? Static::Capture : Static::Normal)}
        elsif request['capture']
          answer += Static::Capture
        end
        protect('replying') {connection.print( (request.xml ? answer : answer.in_skel).to_http )}
        connection.flush()
        connection.close() unless request.keep_alive
      end
    end
  end

  def start_serving
    loop do
      connection = @listener.accept
      log 'Server main loop : new connection'
      Thread.new {handle_connection( connection )}
    end
  end
  
  def to_url
    "http://#{@listen}:#{@port}/"
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
  `rm server.log`
  Servlet::register_all
  $me = Server.new
  File.open( "kemuri.pid", "w" ) {|f| f.print( Process.pid )}
  $me.start_serving
end
