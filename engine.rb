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

class ITPP
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
  attr_accessor :type, :xml
  def initialize type, path, options, post
    @path = path
    @xml = path[0] =~ /\.xml$/
    path[0].gsub!( /\.xml$/, '' )
    @options = options
    @type = type
    @post = post

    log self.inspect
    to_history( to_url )# keep this for the record
  end

  def to_url
    $me.to_url + @path.join( '/' ) + '?' + @options.map{|e| e*"=" }.join( '&' )
  end

  def to_urlxml
    @path[0] += '.xml' unless @xml
    $me.to_url + @path.join( '/' ) + '?' + @options.map{|e| e*"=" }.join( '&' )
  end

  def [] i
    if i.is_a?( Fixnum )
      @path[i]
    else
      @options[i]
    end
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
          #if v.is_a? Array
          #  v.map{|e| k.to_s + "=\"" + e.to_s + "\" "}.join
          #else
            k.to_s + "=\"" + v.to_s + "\" "
          #end
      }.join
       #log "tag:#{u} & #{s}"  
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
    Request.new( type, real_path, options_hash, post_data )
  end

  def to_http
    "HTTP/1.0 200 OK\n\r\n\r" + self
  end

  def in_skel
<<EOP
<html>
<head>
 <meta http-equiv="content-type" content="text/html;charset=utf-8"/>
 <meta name="viewport" content="width=device-width, user-scalable=no"/>
 <meta name="apple-mobile-web-app-capable" content="yes">
 <meta name="apple-mobile-web-app-status-bar-style" content="black">
 <title>煙</title>
</head>
<body onload="javascript:window.scrollTo(0, 1)">
 #{self}
</body>
</html>
EOP
  end

  def to_row
    "<td>#{self}</td>"
  end

  def a url
    "<a href='#{url}'>#{self}</a>"
  end

  def style ele = nil
    return "<style type='text/css'>#{self}</style>" unless ele
    "<span style='#{ele}'>#{self}</span>"
  end

  def script
    "<script type='text/javascript' charset='utf-8'>#{self}</script>"
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
 
  def cut n
    return [] if size == 0
    res = []
    each_with_index do |c,i|
      res << [] if i % n == 0
      res[-1] << c
    end
    res
  end

  def to_table
    w = max {|l,k| l.size <=> k.size}
    map {|l| l.to_row( w.size ).tag( 'tr' )}.join.tag( 'table' ) #, :style => 'font-size:2em' )
  end

  def to_row w
    span = w/size 
    opt = span > 1 ? {'colspan' => span} : {}
    map {|c| c.to_s.tag( 'td' , opt )}.join
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
