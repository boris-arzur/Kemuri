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

#if RUBY_VERSION == '1.9.0'
#  #print Encoding.default_external
#elsif RUBY_VERSION > '1.9.0'
#  Encoding.default_external="UTF-8"
#  Encoding.default_internal="UTF-8"
#else
#  $KCODE = 'u' # pour le split //
#end

#def plog *t
#  log t.map{|i| i.inspect}.join("\n")
#end
#
#$log_mx = Mutex.new
#$log_bf = []
#
#$history_mx = Mutex.new
#$history_bf = []
#
#def log(*t)
#  t = t[0] if t.size == 1
#  $log_mx.synchronize do $log_bf << "[@#{Time.new.to_i.to_s(36)}] #{t}" end
#end
#
#def to_history(t)
#  $history_mx.synchronize do $history_bf << t end
#end
#
#def message(m)
#  $me.message(m)
#end

require './engine.rb'
require './dbs.rb'
require './static.rb'
require './kanji_table.rb'

#class Server
#  def initialize()
#    @port = $kemuri_port || 8185
#    @name = 'Kemuri'
#    @listen = $kemuri_bind || '127.0.0.1'
#
#    @listener = ::TCPServer.new(@listen, @port)
#    @message_mutex = Mutex.new
#    @message = false
#    log('Running on Ruby ' + RUBY_VERSION)
#    log("Bound to #{@listen}:#{@port}.")
#  end
#
#          @message_mutex.synchronize do
#            if @message
#              answer = "<div style='color:red'>#{@message}</div>" + answer
#              @message = false
#            end
#          end
#
#
#  def to_url
#      raise 
#    "/"
#  end
#
#  def message(m)
#      raise 
#    m = "/!\\ #{m} /!\\"
#    @message_mutex.synchronize do
#      if @message
#        @message += "<br/>#{m}"
#      else
#        @message = m
#      end
#    end
#  end
#end

class Servlets
  @@servlets = {}

  Ext = /\.sv\.rb$/

  def self.register_all
    Kemuri.files.each do |file|
      Servlets::register(file) if file =~ Ext
    end
  end

  def self.register(file)
    load(file)
    name = file.gsub(Ext , '')
    @@servlets[name] = eval(name.capitalize + '.new')
  end

  def self.execute(request, path, query, response)
    return "" if path[0] == "favicon.ico"
    @@servlets[path[0]].execute(request, path, query, response)
  end
end

#def server_start
#  `rm server.log;touch server.log`
#  Servlet::register_all
#  $me = Server.new
#  File.open("kemuri.pid", "w") {|f| f.print(Process.pid)}
#  $me.start_flusher
#  $me.start_serving
#end
