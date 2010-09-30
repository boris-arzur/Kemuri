#!/usr/bin/env ruby
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

require 'optparse'
require './server.rb'

def stop_kemuri
  pid = File.read( "kemuri.pid" )
  puts( "Terminating #{pid}." )
  Process.kill( "TERM", pid.to_i )
end

OptionParser.new do |opts|
  opts.banner = "Usage: kemuri.rb [options]"

  opts.on( "-p", "--port [PORT]", "Change default port (8185)." ) do |p|
    $kemuri_port = p.to_i
  end

  #restart
  opts.on( "-r", "--restart", "Restart kemuri." ) do |r|
    stop_kemuri rescue puts( "No instance running ? Anyway, starting Kemuri." )
  end

  #stop
  opts.on( "-s", "--stop", "Stop kemuri." ) do |s|
    stop_kemuri
    Kernel.exit( 0 )
  end
 
end.parse!

puts( "Starting Kemuri." )
$pid = fork do
         server_start
       end

puts( "Kemuri now running, pid = #{$pid}." )

File.open( "kemuri.pid", "w" ) {|f| f.print( $pid )}
Process.detach( $pid )
