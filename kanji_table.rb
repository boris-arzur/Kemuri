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

KanjiTableHTML = File::read( 'kanji_table.html' )
RowSize = 5

def hideable_actionable_content type, text, link_to, tags, id_table
  classnames = "hideable-#{id_table} " + tags.map{|r| "r#{r}"}.join( " " )
  text.a( link_to ).tag( type, 'class' => classnames )
end

def kanji_table sql, req_path, id_table = rand().to_id, url_replace = nil
  raise 'Malformed SQL, need to match /^select [^,\.]*\.{0,1}oid,[^,\.]*\.{0,1}kanji/i' unless sql =~ /^select [^,\.]*\.{0,1}oid,[^,\.]*\.{0,1}kanji/i

  all_rids = Hash.new {|h,k| h[k]=["adzz radz-#{id_table}"]} #kind of a hack : set all radical to have class 'radzz' in the final render, size => 2em
    
  table_of_matches = $db.execute( sql ).map {|kid,kanji|
    rids = $db.execute( "SELECT rid FROM kan2rad WHERE kid = #{kid}" ).map{|rid| rid[0]}
    rids.each{|rid| all_rids[rid] |= (rids - [rid])}
    link_to = url_replace ? req_path.gsub( url_replace, kanji) : req_path+kanji
    hideable_actionable_content( 'td', kanji, link_to, rids, id_table )
  }.cut( RowSize ).map{|row| row.join.tr}.table

  # in case we have no result :
  return Static::voyage if all_rids.size == 0

  radi_cond = all_rids.keys.map{|r| "radicals.oid == #{r}" }*' OR '

  sql = <<EOS
SELECT oid,radical
  FROM radicals 
  WHERE #{radi_cond}
  ORDER BY strokes;
EOS

  radicals = $db.execute( sql ).map {|rid,radi|
    hideable_actionable_content( 'span', radi, "javascript:show_only(\"r#{rid}\",\"#{id_table}\")", all_rids[rid], id_table )
  }.join( " " ).tag( 'div', 'id' => "radicals-#{id_table}" )

  Static::kanji_table( id_table ) + radicals + table_of_matches
end
