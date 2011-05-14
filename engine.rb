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
  attr_accessor :type, :xml, :keep_alive, :post
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

  def to_url(mod_options = {})
    saved_options = @options.clone
		@options.merge!( mod_options )
    url = $me.to_url + @path.join( '/' ) + '?' + @options.map{|k,v| v.is_a?(TrueClass) ? k : "#{k}=#{v}"}.join( '&' )
		@options = saved_options
		url
  end

  def to_urlxml(mod_options = {})
    old_module = @path[0]
    @path[0] += '.xml' unless @xml
    urlxml = to_url(mod_options)
    @path[0] = old_module
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

class Float
  def to_id
    (self * 1_000_000_000).to_i.to_s( 36 )
  end
end

class String
  def extract_options
    options_hash = {}
    split( '&' ).each {|p| 
      k,v = p.split( '=' )
      v ||= true
      if options_hash[k]
        options_hash[k] = [options_hash[k]] unless options_hash[k].is_a?( Array )
        options_hash[k] << v
      else
        options_hash[k] = v
      end
    }
    options_hash
  end

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
    log self.inspect
    split_req = self.split( "\n" )
    raw_path = split_req.find {|l| l =~ /^([^ ]+) /}
    type = $1
    raw_path = raw_path.match( /^#{type} ([^\s]*)\s/ )[1]
    real_path,options = raw_path.split( '?' )
    options ||= ''
    real_path = real_path.split( '/' ).select {|e| e.size > 0}
    raw_post_data = split_req[split_req.find_index( "\r" )+1] || ''
    keep_alive = !!split_req[0].strip =~ /HTTP\/1.1$/
    keep_alive ||= !!split_req.find {|l| l.strip == "Connection: keep-alive"}
    Request.new( type, real_path, options.extract_options, raw_post_data.extract_options, keep_alive )
  end

  def to_http
    "HTTP/1.1 200 OK\r\nDate: #{Time.new.httpdate}\r\nCache-Control: no-cache\r\nAge: 0\r\nContent-Type: text/html; charset=UTF-8\r\nKeep-Alive: timeout=5, max=100\r\nContent-Length: #{self.bytes.to_a.size}\r\n\r\n#{self}"
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
    return yield
  rescue Exception => e
		# fix some pb, with new version of ruby and ol' sqlite3
    log "Error in #{name} : #{e.inspect}\n#{e.backtrace.join( "\n" )}".force_encoding('UTF-8')
    "503. internal error.".a( '/log' )
  end
end
