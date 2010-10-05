#coding:utf-8
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

class Request
  attr_accessor :type, :xml, :keep_alive
  def initialize type, path, options, post, keep_alive = false
    @path = path
    if path[0] =~ /\.xml$/
      @xml = true
      path[0].gsub!( /\.xml$/, '' )
    end
    @options = options
    @type = type
    @post = post
    @keep_alive = keep_alive
  end

  def to_url
    $me.to_url + @path.join( '/' ) + '?' + @options.map{|e| e*"="}.join( '&' )
  end

  def to_urlxml
    @path[0] += '.xml' unless @xml
    urlxml = $me.to_url + @path.join( '/' ) + '?' + @options.map{|e| e*"="}.join( '&' )
    @path[0].gsub!( /\.xml$/, '' )
    urlxml
  end

  def [] i
    if i.is_a?( Fixnum )
      @path[i]
    else
      @options[i]
    end
  end

  def []= i, v
    if i.is_a?( Fixnum )
      @path[i]= v
    else
      @options[i]= v
    end
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

  def url_utf8
    raise 'we will not eval this' unless self.downcase =~ /^(%[0-9a-f]{2})+$/
    byte_form = self.gsub( '%', '\x' )
    #we need to be extra careful here
    eval( '"'+byte_form+'"' )
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

  def parse
    raw_path = self.split( "\n" ).find {|l| l =~ /^([^ ]+) /}
    type = $1
    raw_path = raw_path.match( /^#{type} ([^\s]*)\s/ )[1]
    real_path,options = raw_path.split( '?' )
    options ||= ''
    real_path = real_path.split( '/' ).select {|e| e.size > 0}
    options_hash = {}
    options.split( '&' ).each {|p| 
      k,v = p.split( '=' )
      v ||= true
      if options_hash[k]
        options_hash[k] = [options_hash[k]] unless options_hash[k].is_a?( Array )
        options_hash[k] << v
      else
        options_hash[k] = v
      end
    }
    post_data = self.match( /^\r\n\r\n(.*)$/m )[1] rescue ''
    keep_alive = !!self.split( "\n" ).find {|l| l.strip == "Connection: keep-alive"}
    Request.new( type, real_path, options_hash, post_data, keep_alive )
  end

  def to_http
    "HTTP/1.1 200 OK\n\rDate: #{Time.new.httpdate}\n\rCache-Control: no-cache\n\rAge: 0\n\rContent-Type: text/html; charset=UTF-8\n\rContent-Length: #{self.size}\n\rKeep-Alive: timeout=15, max=100\n\rConnection: Keep-Alive\n\r\n\r#{self}\n\r\n\r"
  end

  def in_skel
<<EOP
<html>
<head>
 <meta name="viewport" content="width=device-width"/>
 <meta name="apple-mobile-web-app-capable" content="yes"/>
 <meta name="apple-mobile-web-app-status-bar-style" content="black"/>
 <title>煙</title>
</head>
<body onload="javascript:window.scrollTo(0, 1)">
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

  def td
    "<td>#{self}</td>"
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
  def map_i
    i = 0
    map {|e|
      r = yield( e,i )
      i += 1
      r
    }
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

  def to_table
    w = max {|l,k| l.size <=> k.size}
    map {|l| l.to_row( w.size )}.table
  end

  def to_row w
    span = w/size 
    opt = span > 1 ? {'colspan' => span} : nil
    map {|c| c.to_s.tag( 'td' , opt )}.join.tr
  end
end

def protect name 
  begin
    return yield
  rescue Exception => e
    log "Error in #{name} : #{e.inspect}\n#{e.backtrace.join( "\n" )}"
    "503. internal error.".a( '/log' )
  end
end
