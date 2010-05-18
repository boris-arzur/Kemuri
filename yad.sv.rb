class Yad
  def execute request
    entry = request[1] || 'start'

    cond_r1 = nil
    cond_r2 = nil

    unless entry.include?( '%' )
      ascii = entry
      cond_r1 = "meanings LIKE '%#{ascii}%'" 
      cond_r2 = "english LIKE '%#{ascii}%'"
    else
      kanji = entry.url_utf8

      #kana ? kanji ?
      kanji_as_num = kanji[1] * 256 + kanji[2]

      if kanji[0] == 227 && kanji_as_num >= 33152 && kanji_as_num <= 33718
        #hira
        cond_r1 = "readings LIKE '%#{kanji}%'"
        cond_r2 = "japanese LIKE '%#{kanji}%'"
      else
        mode = request[2] || 'verbatim'
        kanjis = kanji.split( // )
        cond_r1 = kanjis.map{|k| "kanji = '#{k}'"}.join( ' OR ' )
        cond_r2 = if mode == 'or'
                    kanjis.map{|k| "japanese LIKE '%#{k}%'"}.join( ' OR ' )
                  elsif mode == 'and'
                    kanjis.map{|k| "japanese LIKE '%#{k}%'"}.join( ' AND ' )
                  else
                    "japanese LIKE '%#{kanji}%'"
                  end
      end
    end

    limit = request['limit'] || 10
    r2 = "SELECT * FROM examples WHERE #{cond_r2} LIMIT #{limit}"

    if request['p']
      #si p est def c'est un appel de xmlhttpreq...
      r2 += " OFFSET #{request['p'].to_i*limit.to_i}"
      #p r2
      $db.execute( r2 ).to_table
    else
      r1 = "SELECT kanji, readings, meanings FROM kanjis WHERE #{cond_r1} ORDER BY forder DESC"
      Iphone::voyage + $db.execute( r1 ).to_table + $db.execute( r2 ).to_table + Iphone::next_page( request.to_urlxml )
    end
  end
end
