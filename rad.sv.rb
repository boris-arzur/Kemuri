class Rad
  def execute request
    rad = request[1]
    
    rads = unless rad =~ /^\d+$/
                request[-1].split( '+' ).map {|blk|
                blk.url_utf8
           }.map {|kan|
             $db.get_first_value( "SELECT oid FROM radicals WHERE radical = '#{kan}'" ).to_i
           }
          else
            [rad.to_i]
          end

    rad_cond = "SELECT kid,rid FROM kan2rad WHERE " + rads.map {|rid| "rid = #{rid}"} * " OR "
    r1 = "SELECT kanjis.oid,kanjis.kanji FROM (#{rad_cond}) AS kids LEFT JOIN kanjis ON kids.kid = kanjis.oid ORDER BY kids.rid"
    $db.execute( r1 ).map {|i,e| e.a( '/kan/'+i )} * " "
  end
end
