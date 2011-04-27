# encoding: UTF-8
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

=begin
  // debug code in js
  var debug = "";
  var content = "c";
  var o = elements[0];
  for (var key in o){ content += key +":"+o[key]+"\\n"; };
  alert( content );
=end

class Sk
  Help = "校 &rarr; 1-4-6 ; 思 &rarr ; 2-5-4; 聞 &rarr; 3-8-6 ; 下 &rarr; 4-3-1 ; 土 &rarr; 4-3-2 ; 中 &rarr; 4-4-3 ; 女 &rarr; 4-3-4"

  GuessSwitch = <<-EOS
<input type='checkbox' id='guess' checked='true'/><a href='javascript:toggle_guess()'>guess next</a> &nbsp;
<script type="text/javascript">
function toggle_guess() {
  document.getElementById( 'guess' ).checked = !document.getElementById( 'guess' ).checked;
};

function catchLinks(event) {
  if( event.target.href && // user is clicking a link
      event.target.href.indexOf( 'javascript' ) == '-1' && // not clicking a radical
      document.getElementById( 'guess' ).checked ) { // we actually want to guess :)
    go_to( event.target + '&guess' );
    return false;
  };

  return true;
}

document.onclick=catchLinks;
</script>
EOS

  def guess request
		first = request['first'].url_utf8
    log "guess : #{request[1]} with #{first}"
    
    req1 = if request[1].split( '-' ).size == 1
          "SELECT kanji FROM kanjis WHERE strokes = #{request[1]} ORDER BY forder DESC"
        else
          "SELECT kanji FROM kanjis WHERE skip = '#{request[1]}' ORDER BY forder DESC"
        end

		res_set = $db.execute( req1 )

		cond = res_set.map{|k| "japanese LIKE '%#{first}#{k[0]}%'"}.join( ' OR ' )
    r = "SELECT * FROM examples WHERE #{cond}"
    $db.execute( r ).to_table + Static::voyage
  end

  def execute request
    code = request[1]
    return Help + Static::voyage unless code
    return guess( request ) if request['guess']
    
    code = code.split( '-' )
    
    stroke_count_mode = code.size == 1 || code.size == 2
    double_skip = code.size == 6 || code.size == 2

    if double_skip && !stroke_count_mode
      req_path = "/sk/#{code[3..5]*'-'}?first="
			postfix = "?first="
    elsif double_skip && stroke_count_mode
      req_path = "/sk/#{code[1]}?first="
			postfix = "?first="
    elsif request['first']
      req_path = "/yad/"+request['first'].url_utf8
		  postfix = ''
    else
      req_path = '/kan/'
		  postfix = ''
    end

    guess_switch = double_skip ? GuessSwitch : ''

    r1 = if stroke_count_mode
           "SELECT OID,kanji FROM kanjis WHERE strokes = #{code[0]} ORDER BY forder DESC"
         else
           "SELECT OID,kanji FROM kanjis WHERE skip = '#{code[0..2]*'-'}' ORDER BY forder DESC"
         end

    t,a,b = code[0..2].map {|e| e.to_i}
    glisse = if stroke_count_mode
               Static::glisse( '/sk/', t-1, t+1, t-1, t+1, postfix )
             else
               Static::glisse( "/sk/#{t}-","#{a-1}-#{b}","#{a+1}-#{b}","#{a}-#{b-1}","#{a}-#{b+1}", postfix )
             end

    guess_switch + kanji_table( r1, req_path )  + Static::voyage + glisse 
  end
end
