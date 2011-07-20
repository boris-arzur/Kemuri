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
require './mime_types.rb'

class DataBlob
  def initialize request
    range = request.range
    if range
      range = range.map {|e| e.to_i}
      beginning = range[0]
      length = range[1] - range[0]
    else
      beginning = 0
      length = nil
    end

    filename = 'files/' + request[1].gsub( '%20', ' ' )
    @inner = File::read( filename, length, beginning )
    @mime = $mime_types[filename.split( '.' )[-1]]
  end

  def to_http
    @inner.to_http @mime
  end
end

class Files 
  def execute request
    if !request[1]
      Files::list 
    else
      Files::send request
    end
  end

  def self.list
    Dir::entries( 'files' ).sort.map {|f| [f.a( 'files.xml/'+f ), $mime_types[f.split( '.' )[-1]]]}.to_table
  end

  def self.send request
    DataBlob.new request
  end
end
