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
 
`rm server.log`
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
  def initialize( options = {} )
    @port = options[:port] || 8185
    @name = options[:name] || 'iTouch and JLPT3'
    @listen = options[:listen] || '127.0.0.1'

    @listener = ::TCPServer.new( @listen, @port )
    log( 'Running on Ruby ' + RUBY_VERSION )
  end

  def start
    loop do
      connection = @listener.accept
      
      Thread.new do
        request = ''
        protect( 'reading' ) do
          IO.select([connection]) 
          request = connection.recv_nonblock(100000)
        end

        request = protect('parsing') {request.parse()}
        answer = protect('executing') {Servlet::execute( request )}
        protect('replying') {connection.print( request.xml ? answer : answer.in_skel.to_http )}  
        connection.close()
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
    ITPP.files.each do |file|
      Servlet::register( file ) if file =~ Ext
    end

    @@servlets.default = ::Quatrecentquatre.new
    log( @@servlets.inspect )
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

Servlet::register_all
$me = Server.new

