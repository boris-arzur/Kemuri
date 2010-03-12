class Rad
  def execute request
    rad = request[1]
    
    unless rad =~ /^\d+$/
      bytes = request[-1].split( '%' )[1..-1]
      utf8 = " " * bytes.size
      bytes.each_with_index {|b,i|
        utf8[i] = b[0].hex_to_i * 16 + b[1].hex_to_i
      }

      rad = $db.get_first_value( "SELECT oid FROM radicals WHERE radical = '#{utf8}'" )
    end

    rad = rad.to_i

    r1 = "SELECT kanjis.oid,kanjis.kanji FROM (SELECT kid FROM kan2rad WHERE rid = #{rad}) AS kids LEFT JOIN kanjis ON kids.kid = kanjis.oid;"
    $db.execute( r1 ).map {|i,e| e.a( '/kan/'+i )} * " "
  end
end
