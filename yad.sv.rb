class Yad
  def execute request
    unless request[1].include?( '%' )
      ascii = request[1]
    else
      bytes = request[1].split( '%' )[1..-1]
      kanji = " " * bytes.size
      bytes.each_with_index {|b,i|
        kanji[i] = b[0].hex_to_i * 16 + b[1].hex_to_i
      }

      #kana ? kanji ?
      kanji_as_num = kanji[1] * 256 + kanji[2]
    end

    mode = request[2] || 'verbatim'
    
    if ascii
      #ascii !
      r1 = "SELECT kanji, readings, meanings FROM kanjis WHERE meanings LIKE '%#{ascii}%' ORDER BY forder DESC"
      r2 = "SELECT * FROM examples WHERE english LIKE '%#{ascii}%'"
      $db.execute( r1 ).to_table + $db.execute( r2 ).to_table
    elsif kanji[0] == 227 && kanji_as_num >= 33152 && kanji_as_num <= 33439
      #kana !
      r1 = "SELECT kanji, readings, meanings FROM kanjis WHERE readings LIKE '%#{kanji}%' ORDER BY forder DESC"
      r2 = "SELECT * FROM examples WHERE japanese LIKE '%#{kanji}%'"
      $db.execute( r1 ).to_table + $db.execute( r2 ).to_table
    else
      #kanji !
      r1 = "SELECT kanji, readings, meanings FROM kanjis WHERE "+ kanji.split( // ).map{|k| "kanji = '#{k}'"}.join( ' OR ' ) +" ORDER BY forder DESC"
      condition = if mode == 'or'
                    kanji.split( // ).map{|k| "japanese LIKE '%#{k}%'"}.join( ' OR ' )
                  elsif mode == 'and'
                    kanji.split( // ).map{|k| "japanese LIKE '%#{k}%'"}.join( ' AND ' )
                  else
                    "japanese LIKE '%#{kanji}%'"
                  end

      r2 = "SELECT * FROM examples WHERE " + condition
      $db.execute( r1 ).to_table + $db.execute( r2 ).to_table
    end
  end
end
