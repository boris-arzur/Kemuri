#!/usr/bin/env ruby
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

#Change to Kemuri directory.
#We need that for the load './ --- '
Dir.chdir( File.dirname( $PROGRAM_NAME ) )

require 'optparse'
require './server.rb'

def do_fork
  raise 'Fork failed !' if (pid = fork) == -1
  if not pid.nil?
    #We are the parent : detach and return
#    Process.detach( pid )
    Kernel.exit( 0 )
  end
end

def stop_kemuri
  pid = File.read( "kemuri.pid" )
  puts( "Terminating #{pid}." )
  Process.kill( "TERM", pid.to_i )
end

daemon = true
OptionParser.new do |opts|
  opts.banner = "Usage: kemuri.rb [options]"

  opts.on( "-p", "--port [PORT]", "Change default port (8185)." ) do |p|
    $kemuri_port = p.to_i
  end

  opts.on( "-t", "--time [S]", "Change sleep time for the flushing thread (10)." ) do |t|
    $sleep_time = t.to_i
  end

  opts.on( "-r", "--restart", "Restart kemuri." ) do |r|
    stop_kemuri rescue puts( "No instance running ? Anyway, starting Kemuri." )
  end

  opts.on( "-s", "--stop", "Stop kemuri." ) do |s|
    stop_kemuri
    Kernel.exit( 0 )
  end

  opts.on( "-f", "--foreground", "Do not daemonize." ) do
    daemon = false
  end  
end.parse!

#And now we start the real work.
puts( "Starting Kemuri." )

if daemon
  #Double-forking Unix daemon initializer.
  #raise 'Must run as root' if Process.euid != 0

  do_fork

  Process.setsid
  do_fork

  puts "Daemon supposed pid: #{Process.pid}"
#Well we could be running somewhere
#else, so we don't save the pid here.
#We want to make sure the port is available
#first.

  File.umask( 0000 )

  STDIN.reopen( '/dev/null' )
  STDOUT.reopen( '/dev/null', 'a' )
  STDERR.reopen( STDOUT )
end

#Start the server per se.
#We put it in a big rescue to dump
#some log, should something happen
#to it.

begin
  server_start
rescue Exception => e
  File.open( 'error.log', 'a' ) {|f|
    f.puts "#{Time.now} : #{e.inspect} @ #{e.backtrace.join( "\n" )}"
  }
end
