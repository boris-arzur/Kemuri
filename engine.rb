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
  def initialize path , options
    @path = path
    @options = options

    log self.inspect
  end

  def to_url
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
  def is_num
     self =~ /^\d+$/
  end

  def tag( u , p = nil )
     if p
       "<#{u} #{p.map{|k,v| k.to_s + "=\"" + v.to_s + "\" "}}>#{self}</#{u}>"
     else
       "<#{u}>#{self}</#{u}>"
     end
  end

  def escape
    self.gsub( /</ , '&lt;' ).gsub( />/ , '&gt;' )
  end

  def parse()
    raw_path = self.split( "\n" ).select {|l| 
      l =~ /^GET/
    }[0].match( /^GET ([^\s]*)\s/ )[1]

    real_path,options = raw_path.split( '?' )
    options ||= ''
    real_path = real_path.split( '/' ).select {|e| e.size > 0}
    options_hash = {}
    options.split( '&' ).each {|p| 
      k,v = p.split( '=' )
      v ||= true
      options_hash.store( k,v )
    }

    Request.new( real_path,options_hash )
  end

  def to_http()
    "HTTP/1.0 200 OK\n\r\n\r" + self
  end

  def in_skel()
<<EOP
<html>
<head>
 <meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\"/>
 <meta name=\"viewport\" content=\"width=device-width, user-scalable=no\"/>
 <title>煙</title>
</head>
<body onload="javascript:window.scrollTo(0, 1)">
 #{self}
</body>
</html>
EOP
  end

  def to_row()
    "<td>#{self}</td>"
  end

  def a url
    "<a href='#{url}'>#{self}</a>"
  end

  def style( ele = nil )
    return "<style type='text/css'>#{self}</style>" unless ele
    "<span style='#{ele}'>#{self}</span>"
  end

  def script
    "<script type='text/javascript' charset='utf-8'>#{self}</script>"
  end
end


class Array
  def to_table()
    w = max {|l,k| l.size <=> k.size}
    map {|l| l.to_row( w.size ).tag( 'tr' )}.join.tag( 'table' ) #, :style => 'font-size:2em' )
  end

  def to_row( w )
    span = w/size 
    opt = span > 1 ? {'colspan' => span} : {}
    map {|c| c.to_s.tag( 'td' , opt )}.join
  end
end

def protect( name )
  begin
    return yield
  rescue Exception => e
    log "Error in #{name} : #{e.inspect}\n#{e.backtrace.join( "\n" )}"
    "503. internal error.".a( '/log' )
  end
end

class Fixnum
  def hex_to_i
    self >= 65 ? (self-65) + 10 : (self-48)
  end
end
