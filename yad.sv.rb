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

class Yad
  def find what, options = {}
    if what.is_a?( Array )
      what.map{|k| "#{options[:field]} LIKE '%#{k}%'"}.join( options[:logic] )
    else
      "#{options[:field]} LIKE '%#{what}%'"
    end
  end
 
  def linkify_kanjis! text
    # 一 is the first kanji, in lexicographic order
    # it verifies "一" > kana & ascii
    modded_text = text.split( // ).map {|c| c >= "一" ? c.a( '/kan/'+c ) : c}.join
    text.replace( modded_text )
  end

  def execute request
=begin
  ** Code flow : **

First call, from the user on his browser : /yad/#{p} where p is ascii or url-encoded utf8.
  different fields are queried with different logical connectors, wether p is pure ascii, kana or kanjis.

Second call and subsequent calls, from js' xmlhttprequest :
  with the p= or pairs= option, queries for different pages of the sql request.
  when all results are exhausted, we switch to pairs= if we were querying for p=
    and we stop the ajax autoscroll if we were already querying for pairs=.
=end
    if request[1] and not request.xml
      to_history( '/yad/' + request[1] )
			log 'we logged (in history.log) : ' + request.inspect
		end
		
    entry = request[1] || 'start'
    entry.gsub!( '%20', ' ' )
    cond_r1 = nil
    cond_r2 = nil

    unless entry.include?( '%' )
      #entry is pure ascii
      cond_r1 = find( entry, :field => "meanings" )
      cond_r2 = find( entry, :field => "english" )
    else
      kanji = entry.url_utf8
      
      #kana ? kanji ?
      # 一 is the first kanji, in lexicographic order
      # ぁ is the mother of all kana
      if kanji >= "ぁ" && kanji < "一" 
        #hira
        cond_r1 = find( kanji, :field => "readings" )
        cond_r2 = find( kanji, :field => "japanese" )
      else
        kanjis = kanji.split( // )
        if request['pairs']
           #dont bother if not enough kanjis
           return 'finished();' if kanjis.size < 3
					 start = request['alt'] ? 1 : 0
           cond_r2 = find( kanjis.cut( 2, start ).find_all {|p| p.size == 2}, :field => "japanese" )
			  else
          cond_r1 = find( kanjis, :field => "kanji", :logic => "OR" )
          cond_r2 = find( kanji, :field => "japanese" )
        end
      end
    end

    limit = request['limit'] || 10
    r1 = "SELECT oid, kanji, readings, meanings FROM kanjis WHERE #{cond_r1} ORDER BY forder DESC"
    r2 = "SELECT * FROM examples WHERE #{cond_r2} LIMIT #{limit}"
		
		if request.xml && request['kb']
      #on demande le kanji breakdown
			log "exe : #{r1}"
      rez = $db.execute( r1 ).map {|i,k,r,m| [k.a( '/kan/'+i.to_s ),r,m].to_row( 3 )}.table
			return "append( \"#{rez.gsub( /"/, '\\"' )}\" );"
    elsif request.xml && (request['p'] || request['pairs']) 
      #c'est un appel de xmlhttpreq, par ajax (requete d'une nouvelle page).
      page = request['p'] || request['pairs']
      r2 += " OFFSET #{page.to_i*limit.to_i}"
			log "exe : #{r2}"
      rez = $db.execute( r2 )
      content_table = rez.to_table
      linkify_kanjis!( content_table ) if request['links']
      
      javascript = "append( \"#{content_table.gsub( /"/, '\\"' )}\" );"

      if rez.size < limit
        if request['pairs']
          javascript += 'finished();'
        else
          javascript += 'do_pairs();'
        end
      end

      return javascript
    else
			log "exe : #{r2}"
      dynamic_content = $db.execute( r2 )
			if dynamic_content.size == 0
			  log "exe : #{r1}"
        dynamic_content = $db.execute( r1 ).map {|i,k,r,m| [k.a( '/kan/'+i.to_s ),r,m].to_row( 3 )}.table
			else
				dynamic_content = dynamic_content.to_table
			end

      xml_url = request.to_urlxml
      linkify_kanjis!( dynamic_content ) if request['links']

      log "cck this : " + xml_url 
      Static::voyage + dynamic_content +
        Static::next_page( xml_url ) +
        Static::yad_bar( request )
    end
  end
end
