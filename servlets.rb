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

require './engine.rb'
require './dbs.rb'
require './static.rb'
require './kanji_table.rb'

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
