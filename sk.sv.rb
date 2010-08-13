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

    style = "TD{font-size:3.5em;}".tag( 'style', 'type' => 'text/css' )
    table_of_matches = table_of_matches.tag( 'table' )

    Iphone::glisse( "/sk/#{t}-","#{a-1}-#{b}","#{a+1}-#{b}","#{a}-#{b-1}","#{a}-#{b+1}" ) + 
      table_of_matches + style + Iphone::voyage
  end
end
