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

$db.create_function( 'STROKNT', 1 ) do |func,skip| 
  begin
    t,a,b = skip.to_s.split( '-' ).map{|e| e.to_i}
    func.result = (t == 4) ? (a) : (a+b)
  rescue
    func.result = 0
  end
end


class Sk
  RowSize = 5
  Help = "校 &rarr; 1-4-6 ; 思 &rarr ; 2-5-4; 聞 &rarr; 3-8-6 ; 下 &rarr; 4-3-1 ; 土 &rarr; 4-3-2 ; 中 &rarr; 4-4-3 ; 女 &rarr; 4-3-4"
  GuessSwitch = <<-EOS
<input type='checkbox' id='guess' checked='true'/>guess next<br/>
<script type="text/javascript">
function catchLinks(event) {
  if( event.target.href && // user is clicking a link
      event.target.href.indexOf( 'javascript' ) == '-1' && // not clicking a radical
      document.getElementById( 'guess' ).checked ) { // we actually want to guess :)
    window.location = event.target + '&guess';
    return false;
  };

  return true;
}

document.onclick=catchLinks;
</script>
EOS

  ShowOnly = <<-EOS
<script type="text/javascript">
function show_only(id) {
  var elements = document.getElementsByClassName('hideable');
  for(var i = 0;i < elements.length;i++){
    var ele = elements[i];
    if( ele.className.indexOf( id ) == -1 ) ele.style.display = "none";
  };
};
</script>
EOS

  TableStyle = <<-EOS
<style type="text/css" >TD{font-size:3.5em;}</style>
EOS

  def hideable_actionable_content type, text, link_to, tags
    classnames = 'hideable ' + tags.map{|r| 'r'+r}.join( " " )
    text.a( link_to ).tag( type, 'class' => classnames )
  end

  def guess request
    log "guess : #{request[1]} with #{request['first'].url_utf8}"
    
    r = if request[1].split( '-' ).size == 1
          "SELECT kanji FROM kanjis WHERE STROKNT( skip ) = '#{request[1]}' ORDER BY forder DESC"
        else
          "SELECT kanji FROM kanjis WHERE skip = '#{request[1]}' ORDER BY forder DESC"
        end

    cond = "japanese LIKE '%#{request['first'].url_utf8}%' AND (" + $db.execute( r ).map{|k| "japanese LIKE '%#{k}%'"}.join( ' OR ' ) + ')'
    
    r = "SELECT * FROM examples WHERE #{cond}"
    $db.execute( r ).to_table + Iphone::voyage
  end

  def execute request
    code = request[1]
    return Help + Iphone::voyage unless code
    return guess( request ) if request['guess']
    
    code = code.split( '-' )
    
    stroke_count_mode = code.size == 1 || code.size == 2
    double_skip = code.size == 6 || code.size == 2
 
    req_path = if double_skip && !stroke_count_mode
                 "/sk/#{code[3..5]*'-'}?first="
               elsif double_skip && stroke_count_mode
                 "/sk/#{code[1]}?first="
               elsif request['first']
                 "/yad/"+request['first'].url_utf8
               else
                 '/kan/'
               end

    guess_switch = double_skip ? GuessSwitch : ''

    r1 = if stroke_count_mode
           "SELECT OID,kanji FROM kanjis WHERE STROKNT( skip ) = '#{code[0]}' ORDER BY forder DESC"
         else
           "SELECT OID,kanji FROM kanjis WHERE skip = '#{code[0..2]*'-'}' ORDER BY forder DESC"
         end

    log r1
    #log $db.execute( "SELECT OID,kanji,skip,STROKNT( skip ) FROM kanjis WHERE STROKNT( skip ) == '7' LIMIT 10;" ).inspect

    all_rids = Hash.new {|h,k| h[k]=[]} 
    
    table_of_matches = $db.execute( r1 ).map {|kid,kanji|
      rids = $db.execute( "SELECT rid FROM kan2rad WHERE kid = #{kid}" ).map{|rid| rid[0]}
      rids.each{|rid| all_rids[rid] |= (rids - [rid])}
      hideable_actionable_content( 'td', kanji, req_path+kanji, rids )
    }.cut( RowSize ).map{|row| row.join.tag( 'tr' )}.join.tag( 'table' )

    radi_cond = all_rids.keys.map{|r| "oid == #{r}"}*' OR '
    radicals = $db.execute( "SELECT oid,radical FROM radicals WHERE #{radi_cond} ORDER BY radical" ).map {|rid,radi|
      hideable_actionable_content( 'span', radi, "javascript:show_only(\"r#{rid}\")", all_rids[rid] )
    }.join( " " )

    t,a,b = code[0..2].map {|e| e.to_i}
    glisse = if stroke_count_mode
               Iphone::glisse( '/sk/', t-1, t+1, t-1, t+1 )
             else
               Iphone::glisse( "/sk/#{t}-","#{a-1}-#{b}","#{a+1}-#{b}","#{a}-#{b-1}","#{a}-#{b+1}" )
             end

    guess_switch + ShowOnly + radicals + glisse + table_of_matches + TableStyle + Iphone::voyage
  end
end
