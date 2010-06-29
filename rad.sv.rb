class Rad
  RowSize = 5
  InterSpace = RowSize * 4

  def select_rads
    r = "SELECT radicals.oid,radicals.radical FROM radicals ORDER BY radicals.radical;"

    table_of_matches = ""
    curr_line = ""

    $db.execute( r ).map {|i,e| "<input type='checkbox' name='rad' value='#{i}'/>#{e.a( '/rad/'+i )}"}.each_with_index do |l,i|
      if i>0 && i % RowSize == 0
        table_of_matches << curr_line.tag( 'tr' )
        curr_line = ""
      end

      if i>0 && i % InterSpace == 0
        table_of_matches << "<tr><td><input type='submit' value='検索'/></td></tr>"
      end

      curr_line << l.tag( 'td' )
    end


    table_of_matches += "<tr><td><input type='submit' value='検索'/></td></tr>"

    style = "TD{font-size:3em;}".tag( 'style', 'type' => 'text/css' )

    style + table_of_matches.tag( "table" ).tag( "form", :action => "/rad/", :method => "get" )
  end

  def execute request
    rads = request["rad"]

    unless rads
      rads = request[1]

      if rads =~ /^\d+$/
        rads = [rads.to_i]
      elsif rads
        rads = rads.split( '+' ).map {|blk| blk.url_utf8 }.map {|kan|
          $db.get_first_value( "SELECT oid FROM radicals WHERE radical = '#{kan}'" ).to_i
        }
      else
        return select_rads
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

    style = "TD{font-size:3.5em;}".tag( 'style', 'type' => 'text/css' )
    table_of_matches = table_of_matches.tag( 'table' )

    table_of_matches + style + Iphone::voyage
  end
end
