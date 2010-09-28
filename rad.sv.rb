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
  InterSpace = RowSize * 4

  def select_rads
    r = "SELECT radicals.oid,radicals.radical FROM radicals ORDER BY radicals.radical;"

    table_of_matches = ""
    curr_line = ""

    $db.execute( r ).map {|i,e| "<input type='checkbox' name='rad' value='#{i}'/>#{e.a( "/rad/#{i}" )}"}.each_with_index do |l,i|
      if i>0 && i % RowSize == 0
        table_of_matches << curr_line.tag( 'tr' )
        curr_line = ""
      end

      if i>0 && i % InterSpace == 0
        table_of_matches << "<tr><td><input type='submit' value='検索'/></td></tr>"
      end

      curr_line << l.tag( 'td' )
    end


    table_of_matches += "<tr><td><input type='submit' value='検索'/></td></tr>"

    style = "TD{font-size:3em;}".tag( 'style', 'type' => 'text/css' )

    style + table_of_matches.tag( "table" ).tag( "form", :action => "/rad/", :method => "get" ) + Iphone::voyage
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
