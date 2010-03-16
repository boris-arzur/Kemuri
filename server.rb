require 'thread'
require 'socket'
require 'yaml'

$KCODE = 'u' # pour le split //


`rm server.log`
def log( t )
  File::open( 'server.log' , 'a' ) {|f| f.puts( t )}
end

require 'engine.rb'
require 'dbs.rb'
require 'iphone.rb'

class Server
  def initialize( options = {} )
    @port = options[:port] || 8185
    @name = options[:name] || 'iTouch and JLPT3'
    @listen = options[:listen] || '127.0.0.1'

    @listener = ::TCPServer.new( @listen, @port )
  end

  def start
    loop do
      connection = @listener.accept
      
      Thread.new do
        request = ''
        protect( 'reading' ) do
          while (new_content = connection.gets).chop.length != 0
            request += new_content
          end
        end

        request = protect('parsing') {request.parse()}
        answer = protect('executing') {Servlet::execute( request )}
        protect('replying') {connection.print( answer.in_skel.to_http )}
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

