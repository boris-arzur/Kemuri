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
#gen condi pr les req sql
  def self.find what, options = {}
    whiskers = (options[:ope]||options[:half_whiskers]) ? '' : '%' #remove them % if we are using ==
    options[:ope] ||= 'LIKE'
    if what.is_a?(Array)
      what.map{|k|
        raise "invalid char in k : #{k}" if k.include?("'")
        " #{options[:field]} #{options[:ope]} '#{whiskers}#{k}#{whiskers}' "
      }.join(options[:logic])
    else
      raise "invalid char in what : #{what}" if what.include?("'")
      "#{options[:field]} #{options[:ope]} '#{whiskers}#{what}%'"
    end
  end
  
#cree des liens sur ts les kan
  def self.linkify_kanjis! text
    # 一 is the first kanji, in lexicographic order
    # it verifies "一" > kana & ascii
    modded_text = text.split(//).map {|c| c >= "一" ? c.a('/kan/'+c) : c}.join
    text.replace(modded_text)
  end

#entry point
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
    to_history('/yad/' + request[1]) if request[1] and not request.xml
        
    entry = request[1] || 'start'
    entry.gsub!('%20', ' ')
   
    cond_r1 = nil
    cond_r2 = nil
    valid_pairs = false #display 'pairs' & 'alt' buttons
    valid_kb = false # same same with k.b.
    valid_fuzz = false # guess :)

    unless entry.include?('%')
      #entry is pure ascii
      cond_r1 = Yad::find(entry, :field => "meanings")
      cond_r2 = Yad::find(entry, :field => "english")
    else
      kanji = entry.url_utf8
      valid_fuzz = true

      #kana ? kanji ?
      # 一 is the first kanji, in lexicographic order
      # ぁ is the mother of all kana
      if kanji[0] >= "ぁ" && kanji[0] < "一"
        #kana
        cond_r1 = Yad::find(kanji, :field => "readings")
        cond_r2 = Yad::find(kanji, :field => "japanese")
      else
        kanjis = kanji.split(//)
        valid_pairs = kanjis.size >= 3
        valid_kb = true

        if request['pairs']
          #dont bother if not enough kanjis
          return JSON.new({ 
                             "content_as_html" => "too small to use pairs lookup<br/>",
                             "last_row" => 0, 
                             "fin" => true, 
                             "pairs" => false 
                           }.to_json) if !valid_pairs
          start = request['alt'] ? 1 : 0
          cond_r2 = Yad::find(kanjis.cut(2, start).find_all {|p| p.size == 2}.map{|p| p.join}, :field => "japanese", :logic => "OR")
          #log cond_r2
        else
          cond_r1 = Yad::find(kanjis, :field => "kanji", :logic => "OR", :ope => "==")
          cond_r2 = Yad::find(kanji, :field => "japanese", :half_whiskers => true)
        end
      end
    end

    limit = request['limit'] || 10
    r1 = "SELECT oid, kanji, readings, meanings FROM kanjis WHERE #{cond_r1} ORDER BY forder DESC"
        
    if request.xml && request['kb']
      #on demande le kanji breakdown
      #log "exe1 : #{r1}"
      rez = $db.execute(r1).map {|i,k,r,m| [k.a('/kan/'+i.to_s),r,m]}.to_table
      return JSON.new({ "content_as_html" => rez, "last_row" => 0, "fin" => true, "pairs" => false }.to_json)
    elsif request.xml && (request['p'] || request['pairs'])
      #c'est un appel de xmlhttpreq, par ajax (requete d'une nouvelle page) donc c'est un fuzz ou un pair
      last_oid = request['p'] || request['pairs']
      cond_r2 = Yad::find(kanji, :field => "japanese") if request['fuzz'] #on regenere la condi si on est en fuzz
      #on regen de tte facon la req, pr inserer la condi sur OID
      r2 = "SELECT OID, japanese, english FROM examples WHERE OID > #{last_oid.to_i} AND (#{cond_r2}) LIMIT #{limit}"
      #log "exe2 : #{r2}"
      rez = $db.execute(r2)
      this_last_oid = rez[-1][0] rescue 0
      rez.map! {|oid,jp,en| [jp,en]}
      content_table = rez.to_table
      Yad::linkify_kanjis!(content_table) if request['links']

      json = { "content_as_html" => content_table, "last_row" => this_last_oid, "fin" => false, "pairs" => false }
      if rez.size < limit
        if request['pairs']
          json["fin"] = true
        else
          json["pairs"] = true
        end
      end

      return JSON.new(json.to_json) 
    else
      r2 = "SELECT OID, japanese, english FROM examples WHERE #{cond_r2} LIMIT #{limit}"
      #log "exe3 : #{r2}"
      dynamic_content = $db.execute(r2)
      this_last_oid = dynamic_content[-1][0] rescue 0
      dynamic_content.map! {|oid,jp,en| [jp,en]}
      start_nextpage_js = dynamic_content.size >= limit 

      if dynamic_content.size == 0 && valid_kb # valid_kb means entry is kanji
        cond_r2 = Yad::find(kanji, :field => "japanese")
        r2 = "SELECT OID, japanese, english FROM examples WHERE #{cond_r2} LIMIT #{limit}"
        #log "exe5 : #{r2}"
        dynamic_content = $db.execute(r2)
        this_last_oid = dynamic_content[-1][0] rescue 0
        dynamic_content.map! {|oid,jp,en| [jp,en]}
        unless dynamic_content.size > 0
          #log "exe4 : #{r1}"
          dynamic_content = $db.execute(r1).map {|i,k,r,m| [k.a('/kan/'+i.to_s),r,m]}
          start_nextpage_js = false 
        end
      end

      dynamic_content = dynamic_content.to_table

      xml_url = request.to_urlxml
      Yad::linkify_kanjis!(dynamic_content) if request['links']

      Static::voyage +
        Static::yad_head(request, :pairs => valid_pairs, :kb => valid_kb, :fuzz => valid_fuzz) +
        dynamic_content +
        Static::next_page(xml_url, start_nextpage_js, this_last_oid) +
        Static::yad_bar(request) + 
        Static::search
    end
  end
end
