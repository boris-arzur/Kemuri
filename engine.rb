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

require 'find'
require 'time'
require 'json'

class Kemuri 
  @@files = nil
  
  def self.files 
    unless @@files
      @@files = []
      Find.find('.') {|p| @@files << p[2..-1]}
    end

    @@files
  end
end

class Fixnum
  def is_num
    true
  end
end

class String
  def cut n
    return [] if size == 0
    res = []
    split( // ).each_with_index do |c,i|
      res << "" if i % n == 0
      res[-1] << c
    end
    res
  end

  def is_num
     self =~ /^\d+$/
  end

  def tag u , p = nil
     if p
       s = p.map {|k,v|
             k.to_s + "=\"" + v.to_s + "\" "
           }.join
       "<#{u} #{s}>#{self}</#{u}>"
     else
       "<#{u}>#{self}</#{u}>"
     end
  end

  def escape
    self.gsub( /</ , '&lt;' ).gsub( />/ , '&gt;' )
  end

  def in_skel
<<EOP
<html>
<head>
 <title>煙</title>
</head>
<body onload="window.scrollTo(0, 1);">
#{self}
</body>
</html>
EOP
  end

  def a url
    "<a href='#{url}'>#{self}</a>"
  end

  def style ele = nil
    return "<style type='text/css'>#{self}</style>" unless ele
    "<span style='#{ele}'>#{self}</span>"
  end

  def script
    "<script type='text/javascript'>#{self}</script>"
  end

  def td opts=''
    "<td#{opts}>#{self}</td>"
  end
  alias :to_row :td  

  def tr
    "<tr>#{self}</tr>"
  end

  def table
    "<table>#{self}</table>"
  end
end


class Array
  def map_i(&b)
    each_with_index.map(&b)
  end
 
  def cut n, start = 0
    return [] if size == 0

    #real stuff begins here
    res = []
    start %= n

    #we need this to initialize
    res << [] if start != 0

    each_with_index do |c,i|
      res << [] if i % n == start
      res[-1] << c
    end
    res
  end

  def table
    join.table
  end

  def to_table opts = {}
    w = max {|l,k| l.size <=> k.size}
    map {|l| l.to_row( w.size, opts[:td_opts] )}.table
  end

  def to_row w, addendum = nil
    addendum ||= {}
    span = w/size 
    opt = span > 1 ? {'colspan' => span} : {}
    opt.merge! addendum
    map {|c| c.to_s.tag( 'td' , opt )}.join.tr
  end
end

def protect name 
  begin
    yield
  rescue Exception => e
		# fix some pb, with new version of ruby and ol' sqlite3
    print "Error in #{name} : #{e.inspect}\n#{e.backtrace.join( "\n" )}".force_encoding('UTF-8')
    "503. internal error.".a( '/log' )
  end
end
