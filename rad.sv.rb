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

class Rad
  def initialize
    Static::add_button('go to radical selection','rad')
  end

  RowSize = 5
  Style = "TD{font-size:3em;}".style
  HDelim = ("<hr size='1'/>".td*RowSize).tr

  GetAllRads = "SELECT oid,radical FROM radicals ORDER BY strokes;"

  def self.to_checkbox(radical, rid)
    "<input type='checkbox' value='#{rid}'/>#{radical.a("/rad/#{rid}")}".tag('td')
  end

  def self.select_rads
    stroke2rad = Hash.new {|h,k| h[k]=[]}
    $db.execute(GetAllRads).each {|i,e,s| stroke2rad[s] << Rad::to_checkbox(e,i)}

    table_of_matches = stroke2rad.sort_by{|s,chkbxz| s.to_i}.map {|s,chkbxz|
      chkbxz.cut(RowSize).map{|row| row.join.tr}.join
    }.join(HDelim).table

    table_of_matches.tag("form", :name => "rads", :id => 'content') + Style + Static::rad_bar
  end

  def execute request, path, query, response
    path = path.map{|p| p.force_encoding(Encoding::UTF_8)}
    if path.size > 1 and path[1..-1].all?{|p| p.is_num}
      rads = path[1..-1]
    elsif path[1]
      rads = path[1].split('+').map {|blk| 
        $db.get_first_value("SELECT oid FROM radicals WHERE radical = ?", [kan])
      }
    else
      return Rad::select_rads
    end

    rad_cond = rads.map {|rid| "SELECT kid FROM kan2rad WHERE rid = #{rid}"} * " INTERSECT "
    r1 = "SELECT kanjis.oid,kanjis.kanji FROM (#{rad_cond}) AS kids LEFT JOIN kanjis ON kids.kid = kanjis.oid ORDER BY kids.kid"

    kanji_table(r1, '/kan/') + Static::voyage
  end
end
