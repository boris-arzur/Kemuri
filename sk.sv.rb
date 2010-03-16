class Sk
  def execute request
    code = request[1]
    return "校 &rarr; 1-4-6 ; 思 &rarr ; 2-5-4; 聞 &rarr; 3-8-6 ; 下 &rarr; 4-3-1 ; 土 &rarr; 4-3-2 ; 中 &rarr; 4-4-3 ; 女 &rarr; 4-3-4" unless code

    t,a,b = code.split( '-' ).map {|e| e.to_i}

    r1 = "SELECT OID,kanji FROM kanjis WHERE skip = '#{code}' ORDER BY forder DESC"

    Iphone::glisse( '/sk/#{t}-','#{a+1}-#{b}','#{a-1}-#{b}','#{a}-#{b-1}','#{a}-#{b+1}' ) + 
      $db.execute( r1 ).map {|i,e| e.a( "/kan/#{i}" )} * " " + Iphone::voyage
  end
end
