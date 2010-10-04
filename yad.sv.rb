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
    options[:field] ||= 'japanese'
    options[:logic] ||= ' OR '

    if what.is_a?( Array )
      what.map{|k| "#{options[:field]} LIKE '%#{k}%'"}.join( options[:logic] )
    else
      "#{options[:field]} LIKE '%#{what}%'"
    end
  end

  def execute request
    to_history( '/yad/' + request[1] ) if request[1]
    entry = request[1] || 'start'
    entry.gsub!( '%20' ,' ' )
    cond_r1 = nil
    cond_r2 = nil

    unless entry.include?( '%' )
      ascii = entry
      cond_r1 = find( ascii, :field => "meanings" )
      cond_r2 = find( ascii, :field => "english" )
    else
      kanji = entry.url_utf8
      
      #kana ? kanji ?
      kanji_as_bytes = kanji.bytes.to_a
      kanji_as_num = kanji_as_bytes[1] * 256 + kanji_as_bytes[2]

      if kanji[0] == 227 && kanji_as_num >= 33152 && kanji_as_num <= 33718
        #hira
        cond_r1 = find( kanji, :field => "readings" )
        cond_r2 = find( kanji )
      else
        mode = request[2] || 'verbatim'
        kanjis = kanji.split( // )
        cond_r1 = find( kanjis, :field => "kanji" )
        cond_r2 = if mode == 'or'
                    find( kanjis )
                  elsif mode == 'and'
                    find( kanjis, :logic => ' AND ' )
                  else
                    find( kanji )
                  end

        if kanjis and kanjis.size > 2
           pairs = find( kanjis.cut( 2 ).map{|pair| pair.join} )
           alt_pairs = find( kanjis.cut( 2, 1 ).map{|pair| pair.join} )
           cond_r2 = [cond_r2,pairs,alt_pairs].join( ' OR ' )
        end
      end
    end

    limit = request['limit'] || 10
    r2 = "SELECT * FROM examples WHERE #{cond_r2} LIMIT #{limit}"
    

    plog cond_r1,r2
    if request['p']
      #si p est def c'est un appel de xmlhttpreq...
      r2 += " OFFSET #{request['p'].to_i*limit.to_i}"
      #p r2
      rez = $db.execute( r2 )
      javascript = "append_html( \"#{rez.to_table}\" );"
      javascript += 'finished();' if rez.size < limit
      return javascript
    else
      r1 = "SELECT oid, kanji, readings, meanings FROM kanjis WHERE #{cond_r1} ORDER BY forder DESC"
      kanjis_table = $db.execute( r1 ).map {|i,k,r,m| ( k.a( '/kan/'+i.to_s ).td + r.td + m.td ).tr}.table
      Iphone::voyage + kanjis_table + $db.execute( r2 ).to_table + Iphone::next_page( request.to_urlxml )
    end
  end
end
