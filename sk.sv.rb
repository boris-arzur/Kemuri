class Sk
  RowSize = 5

  def execute request
    code = request[1]
    return "校 &rarr; 1-4-6 ; 思 &rarr ; 2-5-4; 聞 &rarr; 3-8-6 ; 下 &rarr; 4-3-1 ; 土 &rarr; 4-3-2 ; 中 &rarr; 4-4-3 ; 女 &rarr; 4-3-4" unless code

    t,a,b = code.split( '-' ).map {|e| e.to_i}

    r1 = "SELECT OID,kanji FROM kanjis WHERE skip = '#{code}' ORDER BY forder DESC"

    table_of_matches = ""
    curr_line = ""

    $db.execute( r1 ).map {|i,e| e.a( "/kan/#{i}" )}.each_with_index do |l,i|
      if i>0 && i % RowSize == 0
        table_of_matches << curr_line.tag( 'tr' )
        curr_line = ""
      end
      curr_line << l.tag( 'td' )
    end

    table_of_matches << curr_line.tag( 'tr' )

    style = "TD{font-size:4em;}".tag( 'style', 'type' => 'text/css' )
    table_of_matches = table_of_matches.tag( 'table' )

    Iphone::glisse( "/sk/#{t}-","#{a-1}-#{b}","#{a+1}-#{b}","#{a}-#{b-1}","#{a}-#{b+1}" ) + 
      table_of_matches + style + Iphone::voyage
  end
end
