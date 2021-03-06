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

class Static
  @@voyage_buttons = ""

  def self.load_content file
    if file =~ /.gz$/
      raw_content = Zlib::GzipReader.open( file ) {|gz| gz.read} 
      file = file[0..-4]
    else
      raw_content = File::read( file )
    end

    clean_content = raw_content
    #clean_content = raw_content.gsub( /\/\*.*?\*\//m, '' ).gsub( "\n", "" )

    #while clean_content.gsub!( "  ", " " )
    #end
    
    if file =~ /\.js$/
      clean_content.script
    elsif file =~ /\.css$/
      clean_content.style
    else
      clean_content
    end
  end

  BarStyle = load_content( 'bar.css' )
  VoyageScript = load_content( 'voyage.js' )
  
  Next_pageScript = load_content( 'next_page.js' )

  Rad_barScript = load_content( 'rad_bar.js' )

  def self.kanji_table id_table 
    kanji_table = File::read( 'kanji_table.html' )
    kanji_table.gsub( /#id_table#/, id_table )
  end

  def self.add_button name, path = name
    button = "<button onclick='window.location = \"/#{path}\"'>#{name}</button> "
    @@voyage_buttons << button
  end
  
  def self.look_select max, url
    res = <<-EOS
<script type="text/javascript" charset="utf-8">
var selection = new Array();
function set_visi_class(classname, visi) {
  var elements = document.getElementsByClassName( classname );

  for(var i = 0;i < elements.length;i++)
    elements[i].style.display = visi;
};

function select(id,kan,id_table) {
  selection[id] = kan;
  set_visi_class('hideable-' + id_table, 'none');
  set_visi_class('radz-' + id_table, 'none');

  document.getElementById('radi_up-' + id_table).style.display = 'none';
  document.getElementById('radi_down-' + id_table).style.display = 'none';

  if(selection.length == #{max})  window.location = "#{url}kans=" + selection.toString(); 

  var link = document.createElement('a');
  link.setAttribute('href', 'javascript:reshow("' + id_table + '")');
  link.appendChild( document.createTextNode("Reshow kanji " + id ) );

  var footer = document.getElementById( 'footer' );
  footer.appendChild( link );
  footer.appendChild( document.createElement('br') );
};

function reshow(id_table) {
  set_visi_class('hideable-' + id_table, 'inline');
  set_visi_class('radz-' + id_table, 'inline');

  document.getElementById('radi_up-' + id_table).style.display = 'inline';
  document.getElementById('radi_down-' + id_table).style.display = 'inline';
};
</script>
<div id=footer></div>
EOS
  end

  def self.voyage
    res = <<-EOS
<div id="voyage" class="bar">
  <form onsubmit='voyage_update_options(); return false;'><input type="text" id="dokomade" autocapitalize="off" size='10'/></form>
  <button onclick='voyage_update_options()'>←search</button>
  #{@@voyage_buttons}
</div>
EOS
    res + VoyageScript
  end

  def self.next_page base, start, next_page
    res = <<-EOS
<script type="text/javascript">
  var update = #{start ? 'true' : 'false'};
  var next_page_url_base = "#{base}";
  var glue = "#{(base =~ /\?$/ )?"":"&"}";
  var next_page = #{next_page};
</script>
EOS
    res + Next_pageScript
  end

  def self.rad_bar
    res = <<-EOS
<div id="rad_bar" class="bar">
  <form onsubmit='voyage_update_options(); return false;'><input type="text" id="dokomade" autocapitalize="off" size='10'/></form>
  <button onclick='voyage_update_options()'>←search</button>
  #{@@voyage_buttons}
  <button onclick='send_form()'>search</button>
  <button onclick='rad_bar_clear()'>clear</button>
</div>
EOS
    res + BarStyle + Rad_barScript + VoyageScript
  end

  def self.yad_head request, request_xml, options = {}
    request += request.include?('?') ? "&links" : "?links"
    request.force_encoding(Encoding::UTF_8)
    request_xml += request_xml.include?('?') ? "&kb" : "?kb"

    res = <<-EOS
<div id="yad_bar" class="bar">
  <form onsubmit='voyage_update_options(); return false;'><input type="text" id="dokomade" autocapitalize="off" size='10'/></form>
  <button onclick='voyage_update_options()'>←search</button>
  #{@@voyage_buttons}
  <button onclick='window.location = \"#{request}\"'>make links on all kanjis</button>
EOS

    res += "<button onclick='ajax_get( \"#{request_xml}\" )'>search kanjis one by one</button>" if options[:kb]
    res += "<button onclick='do_fuzz();'>fuzz</button>" if options[:fuzz]
    res += "<button onclick='do_pairs();'>search pairs of kanjis</button><button onclick='do_alt();'>search alternative pairs</button>" if options[:pairs]
    res += "</div>"
    res + BarStyle + VoyageScript
  end
end
