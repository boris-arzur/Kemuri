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
  @@voyage_hidden_buttons = ""

  def self.load_content file
    raw_content = File::read( file )
    clean_content = raw_content.gsub( /\/\*.*?\*\//m, '' ).gsub( "\n", "" )

    while clean_content.gsub!( "  ", " " )
    end
    
    if file =~ /\.js$/
      clean_content.script
    elsif file =~ /\.css$/
      clean_content.style
    else
      clean_content
    end
  end

  Glisse_style = load_content( 'glisse.css' )
  Glisse_script = load_content( 'glisse.js' )

  Voyage_style = load_content( 'voyage.css' )
  Voyage_script = load_content( 'voyage.js' )
  
  Next_page_script = load_content( 'next_page.js' )

  Bar_style = load_content( 'bar.css' )

  Rad_bar_script = load_content( 'rad_bar.js' )
  Yad_bar_script = load_content( 'yad_bar.js' )

  Search_script = load_content( 'search.js' )

  Capture = load_content( 'capture.js' )  
  Normal = "function go_to( normal_url ){window.location = normal_url;}".script

  def self.glisse( url_base, haut, bas, gauche, droite, postfix )
    res = <<-EOS
<script type="text/javascript" charset="utf-8">
  function load() { glisse( '#{url_base}','#{haut}','#{bas}','#{gauche}','#{droite}', '#{postfix}' ); };
  window.addEventListener("load", load, false);
</script>
<div id="glisse"></div>
EOS
    res + Glisse_style + Glisse_script
  end

  def self.add_hidden_button name, path = name
    button = "<button onclick='go_to( \"/#{path}\" )'>#{name}</button> "
    @@voyage_hidden_buttons << button
  end

  def self.voyage
    res = <<-EOS
<div id="voyage">
<input type="text" id="dokomade" autocapitalize="off" size=10/>
<div id="voyage_btns">#{@@voyage_hidden_buttons}</div>
</div>
EOS
    res + Voyage_style + Voyage_script
  end

  def self.next_page base, start
    res = <<-EOS
<script type="text/javascript">
  var update = #{start ? 'true' : 'false'};
  var next_page_url_base = "#{base}";
  var glue = "#{(base =~ /\?$/ )?"":"&"}";
</script>
<div id='add'></div>
<div id='bottom'></div>
EOS
    res + Next_page_script
  end

  def self.rad_bar
    res = <<-EOS
<div id="rad_bar" class="bar">
  <button onclick='send_form()'>検索</button>
  <button onclick='rad_bar_clear()'>消</button>
</div>
EOS
    res + Bar_style + Rad_bar_script
  end

  def self.yad_bar request
    res = <<-EOS
<div id="yad_bar" class="bar">
  <button onclick='go_to( \"#{request.to_url( :links => true )}\" )'>環</button>
</div>
EOS
    res + Bar_style + Yad_bar_script
  end

  def self.yad_head request
    res = <<-EOS
<div id="yad_head">
	<button onclick='ajax_get( \"#{request.to_urlxml( :kb => true )}\" )'>k.b.</button>
	<button onclick='do_fuzz();'>fuzz</button>
	<button onclick='do_pairs();'>pairs</button>
	<button onclick='do_alt();'>alt</button>
</div>
EOS
  end

  def self.search
    res = <<-EOS
<div id="search_bar" class="bar">
  <button onclick='searchPrompt()'>検索</button>
</div>
EOS
    res + Bar_style + Search_script
  end
end
