#!/usr/local/bin/ruby
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

OptionParser.new do |opts|
  opts.banner = "Usage: kemuri.rb [options]"

  opts.on("-p", "--port [PORT]", "Change default port (8185).") do |p|
    $kemuri_port = p.to_i
  end
end.parse!

server_start
