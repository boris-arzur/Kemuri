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

class Rad
  RowSize = 5
  InterSpace = 4
  SrchBtn = "<td><button type='submit' style='width:2em;display:block;'><div style='width:100%'>検索</div></button></td>"
  Style = "<style type='text/css'>TD{font-size:3em;}</style>"
  HDelim = ("<hr size='1'/>".tag('td')*(RowSize+1)).tag('tr')

  GetAllRads = <<EOR
SELECT radicals.oid,radicals.radical,kanjis.strokes
 FROM radicals
 JOIN kanjis ON kanjis.kanji == radicals.radical
 ORDER BY kanjis.strokes;
EOR

  def to_checkbox( radical, rid )
    "<input type='checkbox' name='rad' value='#{rid}'/>#{radical.a( "/rad/#{rid}" )}".tag( 'td' )
  end

  def select_rads
    stroke2rad = Hash.new {|h,k| h[k]=[]}
    $db.execute( GetAllRads ).each {|i,e,s| stroke2rad[s] << to_checkbox(e,i)}

    table_of_matches = stroke2rad.sort_by{|s,chkbxz| s}.map {|s,chkbxz|
      chkbxz.cut( RowSize ).map{|row| (SrchBtn+row.join).tag( 'tr' )}.join
    }.join( HDelim ).tag( "table" ).tag( "form", :action => "/rad/", :method => "get" )

    Style + table_of_matches + Iphone::voyage
  end

  def execute request
    if request["rad"].is_a?( Array )
      rads = request["rad"]
    elsif request["rad"] and request["rad"].is_num
      rads = [request["rad"]]
    elsif request[1] and request[1].is_num
      rads = [request[1]]
    elsif request[1]
      rads = request[1].split( '+' ).map {|blk| 
        kan = blk.url_utf8
        $db.get_first_value( "SELECT oid FROM radicals WHERE radical = '#{kan}'" )
      }
    else
      return select_rads
    end

    rad_cond = rads.map {|rid| "SELECT kid FROM kan2rad WHERE rid = #{rid}"} * " INTERSECT "
    r1 = "SELECT kanjis.oid,kanjis.kanji FROM (#{rad_cond}) AS kids LEFT JOIN kanjis ON kids.kid = kanjis.oid ORDER BY kids.kid"

    kanji_table( r1, '/kan/' ) + Iphone::voyage
  end
end
