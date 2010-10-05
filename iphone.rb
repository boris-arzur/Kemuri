#coding:utf-8
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

class Iphone
  @@voyage_hidden_buttons = ""

  Glisse_style = File::read( 'glisse.css' ).style
  Glisse_script = File::read( 'glisse.js' ).script

  Voyage_style = File::read( 'voyage.css' ).style
  Voyage_script = File::read( 'voyage.js' ).script
  
  Next_page_script =  File::read( 'next_page.js' ).script

  Bar_style = File::read( 'bar.css' ).style

  Rad_bar_script = File::read( 'rad_bar.js' ).script
  Yad_bar_script = File::read( 'yad_bar.js' ).script
  
  def self.glisse( url_base, haut, bas, gauche, droite )
    res = <<-EOS
<script type="text/javascript" charset="utf-8">
  function load() { glisse( '#{url_base}','#{haut}','#{bas}','#{gauche}','#{droite}'); };
  window.addEventListener("load", load, false);
</script>
<div id="glisse"></div>
EOS
    res + Glisse_style + Glisse_script
  end

  def self.add_hidden_button name, path = name
    #@@voyage_hidden_buttons = "<br/>" if @@voyage_hidden_buttons.size == 0
    button = "<button onclick='javascript:window.location=\"/#{path}\"'>#{name}</button> "
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

  def self.next_page base
    res = <<-EOS
<script type="text/javascript">
  var next_page_url_base = "#{base}";
  var glue = "#{(base[-1] != "?")?"&":""}";
</script>
<div id='add'></div>
<div id='bottom'></div>
EOS
    res + Next_page_script
  end

  def self.rad_bar
    res = <<-EOS
<div id="rad_bar" class="bar">
  <button onclick='javascript:document.forms["rads"].submit();'>検索</button>
  <button onclick='javascript:rad_bar_clear();'>消</button>
</div>
EOS
    res + Bar_style + Rad_bar_script
  end

  def self.yad_bar path
    res = <<-EOS
<div id="yad_bar" class="bar">
  <button onclick='javascript:window.location=\"#{path}\"'>環</button>
</div>
EOS
    res + Bar_style + Yad_bar_script
  end
end
