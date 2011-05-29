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

class Look 
  @@mutex = Mutex.new
  @@store = {}

  def execute request
    Look::process request
  end

  def self.start( data )
    log "starting with this : " +data.inspect
    id = rand.to_id
    @@mutex.synchronize {@@store[id] = data}
    log @@store
    req_rewrite = Request.new( false, ['look',id], {}, nil )
    Look::process req_rewrite
  end

  def self.process request
    id = request[1]
    data = @@store[id]

    log "id, data, @@store"
    log [id, data, @@store]

    if !request.type
      rad_i = 0
      rad_j = 0
      radicals_pickup = data.map {|ele| 
        rad_i += 1
        ele[:r].map {|kan| 
          rad_j += 1
          #TODO if just one rad -> change input type 
          [kan.style( 'color:green' ),"&rarr;"]+Kanji.new( kan ).get_radicals.map {|i,e| "<input type='checkbox' name='r#{rad_i}-#{rad_j}' value='#{i}'/>#{e}"}
        }
      }.flatten( 1 )
      
      radicals_pickup << ["<input type=submit value=ok />"]
      radicals_pickup = radicals_pickup.to_table( :td_opts => {:style=>'font-size:3em'} )
      radicals_pickup.tag( "form", :action => request.to_url, :method => "post" ) + Static::voyage
    elsif request.post.keys[0] =~ /^r/
      @@mutex.synchronize do
        rad_i = 0
        rad_j = 0
        data.each do |ele|
          rad_i += 1
          ele[:r].map! {|kan|
            rad_j += 1
            request.post["r#{rad_i}-#{rad_j}"] or (message( "missing a rad ?" ) and 0)
          }
        end
      end
      log data

      data.map_i do |ele,i|
        rads = ele[:r].flatten
        skip = ele[:s]
        
        log ele[:s]

        cond = []
        if skip.is_a?( String ) && skip.split( '-' ).size == 1
          cond << "SELECT oid AS kid FROM kanjis WHERE strokes = #{skip}"
        elsif skip.is_a?( String )
          cond << "SELECT oid AS kid FROM kanjis WHERE skip = '#{skip}'"
        end

        cond += rads.map {|rid| "SELECT kid FROM kan2rad WHERE rid = #{rid}"}
        r1 = "SELECT kanjis.oid,kanjis.kanji FROM (#{cond * " INTERSECT "}) AS kids LEFT JOIN kanjis ON kids.kid = kanjis.oid ORDER BY kids.kid"

        log r1
        table_id = rand.to_id
        kanji_table( r1, "javascript:select(\"#{i}\",\"#kid#\",\"#{table_id}\")", table_id, '#kid#' )
      end * "------<br/>" + Static::voyage + Static::look_select( data.size, request.to_url )
    elsif request['kans']
      id = request[1]
      @@mutex.synchronize do @@store.delete( id ) end

      request[0] = 'yad'
      request[1] = request['kans'].gsub( ',', '' )
      Servlet::execute( request )
    else
      '...'
    end
  end
end