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
 
def log( t )
  File::open( 'server.log' , 'a' ) {|f| f.puts( t )}
end

def to_history( t )
  File::open( 'history.log' , 'a' ) {|f| f.puts( t )}
end

require './engine.rb'
require './dbs.rb'
require './iphone.rb'
require './kanji_table.rb'

class Server
  def initialize()
    @port = $kemuri_port || 8185
    @name = 'Kemuri'
    @listen = '127.0.0.1'

    @listener = ::TCPServer.new( @listen, @port )
    log( 'Running on Ruby ' + RUBY_VERSION )
  end

  def start_serving
    loop do
      connection = @listener.accept
      plog 'new conn'
      Thread.new do
        loop do
          request = ''
          protect( 'reading' ) do
            what = IO.select( [connection], [], [], 5000 )
            if what.nil?
              protect('closing') do
                log 'auto-close keep-alive'
                connection.close()
                break
              end
            end
            request = connection.recv_nonblock( 100000 )
          end
          
          if request == ''
            sleep 0.1
            connection.puts
            log 'mmm'
            next
          end

          log request
          request = protect('parsing') {request.parse()}
          log( request.inspect )
          answer = protect('executing') {Servlet::execute( request )}
          protect('capture_part') {answer += Iphone::capture_links if request['capture']}
          protect('replying') {connection.print( (request.xml ? answer : answer.in_skel).to_http )}
          connection.flush()
          connection.close() unless request.keep_alive
        end
      end
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
