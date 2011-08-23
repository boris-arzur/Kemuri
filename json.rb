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

#minimalist hash -> json implementation
class Fixnum 
  def to_json
    to_s
  end
end

class Float
  def to_json
    to_s
  end
end

class TrueClass
  def to_json
    "true" 
  end
end

class FalseClass
  def to_json
    "false" 
  end
end

class NilClass
  def to_json
    "null" 
  end
end

class String
  def to_json
    inspect 
  end
end

class Symbol
  def to_json
    to_s.inspect
  end
end

class Array
  def to_json
    "[" + map {|e| e.to_json}*"," + "]"
  end
end

class Hash
  def to_json
    "{" + map {|k,v| k.to_json + ":" + v.to_json}*"," + "}"
  end
end

class JSON
  def initialize content
    @content = content
  end

  def to_http
    @content.to_http "200 OK", "application/json"
  end
end

