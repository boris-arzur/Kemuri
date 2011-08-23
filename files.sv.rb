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
    @request = request
    range = request.range
    if range
      @reply_code = "206 Partial Content"
      range = range.map {|e| e.to_i}
      beginning = range[0]
      length = range[1] - range[0] + 1
    else
      @reply_code = "200 OK"
      beginning = 0
      length = nil
    end

    filename = 'files/' + request[1].gsub( '%20', ' ' ).gsub( '%27', "'" )
    @length = File::size filename
    @inner = File::read( filename, length, beginning )
    @mime = $mime_types[filename.split( '.' )[-1]]
  end

  def to_http
    add_cntnt = @request.range ? "Content-Range: bytes #{@request.range*'-'}/#{@length}\r\n" : ''
    @inner.to_http @reply_code, @mime, add_cntnt 
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
    Dir::entries( 'files' ).sort.map {|f| [f.a( 'files.xml/'+f.gsub( '\'', "%27" ) ), $mime_types[f.split( '.' )[-1]]]}.to_table
  end

  def self.send request
    DataBlob.new request
  end
end