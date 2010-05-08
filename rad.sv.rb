class Rad
  def execute request
    rads = request["rad"]

    unless rads
      rads = request[-1]
      unless rads =~ /^\d+$/
        rads = rads.split( '+' ).map {|blk| blk.url_utf8 }.map {|kan|
          $db.get_first_value( "SELECT oid FROM radicals WHERE radical = '#{kan}'" ).to_i
        }
      else
        rads = [rad.to_i]
      end
    end

    rad_cond = rads.map {|rid| "SELECT kid FROM kan2rad WHERE rid = #{rid}"} * " INTERSECT "
    r1 = "SELECT kanjis.oid,kanjis.kanji FROM (#{rad_cond}) AS kids LEFT JOIN kanjis ON kids.kid = kanjis.oid ORDER BY kids.kid"
    $db.execute( r1 ).map {|i,e| e.a( '/kan/'+i )} * " "
  end
end
