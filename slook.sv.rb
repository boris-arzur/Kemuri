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

class Slook 
  def execute request, path, query, response
    expression = path[1] 

    expression.force_encoding(Encoding::UTF_8)
    data = expression.split( "+" ).map {|t| 
      kanji_def = Hash.new {|h,k| h[k] = []}
      t.split( "&" ).each {|e|
        next if e.size == 0
        if e =~ /^[\d]-[_\d]+-[_\d]+$|^[\d]+$/
          kanji_def[:s] = e
        else
          kanji_def[:r] << e
        end
      }
      kanji_def
    }
    Look.new.start(data, request, path, query, response)
  end
end
