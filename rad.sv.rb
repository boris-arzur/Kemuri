class Rad
  RowSize = 5

  def execute request
    rads = request["rad"]

    unless rads
      rads = request[-1]
      unless rads =~ /^\d+$/
        rads = rads.split( '+' ).map {|blk| blk.url_utf8 }.map {|kan|
          $db.get_first_value( "SELECT oid FROM radicals WHERE radical = '#{kan}'" ).to_i
        }
      else
        rads = [rads.to_i]
      end
    end

    rad_cond = rads.map {|rid| "SELECT kid FROM kan2rad WHERE rid = #{rid}"} * " INTERSECT "
    r1 = "SELECT kanjis.oid,kanjis.kanji FROM (#{rad_cond}) AS kids LEFT JOIN kanjis ON kids.kid = kanjis.oid ORDER BY kids.kid"

    table_of_matches = ""
    curr_line = ""

    $db.execute( r1 ).map {|i,e| e.a( '/kan/'+i )}.each_with_index do |l,i|
      if i>0 && i % RowSize == 0
        table_of_matches << curr_line.tag( 'tr' )
        curr_line = ""
      end
      curr_line << l.tag( 'td' )
    end

    table_of_matches << curr_line.tag( 'tr' )

    style = "TD{font-size:4em;}".tag( 'style', 'type' => 'text/css' )
    table_of_matches = table_of_matches.tag( 'table' )

    table_of_matches + style + Iphone::voyage
  end
end
