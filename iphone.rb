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
  Glisse_style = File::read( 'glisse.css' ).style
  Glisse_script = File::read( 'glisse.js' ).script

  Voyage_style = File::read( 'voyage.css' ).style
  Voyage_script = File::read( 'voyage.js' ).script
  
  Next_page_script =  File::read( 'next_page.js' ).script

  Rad_bar_style = File::read( 'rad_bar.css' ).style
  Rad_bar_script = File::read( 'rad_bar.js' ).script

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

  def self.voyage
    res = <<-EOS
<div id="voyage">
<input type="text" id="dokomade" 
       onchange="javascript:voyage_update_options()"
       onfocus="javascript:voyage_focus_input()"
       value="" autocapitalize="off" size=10/>
</div>
EOS
    res + Voyage_style + Voyage_script
  end

  def self.next_page base
    res = <<-EOS
<script type="text/javascript" charset="utf-8">
  var next_page_url_base = "#{base}";
</script>
<div id='add'></div>
<div id='bottom'></div>
EOS
    res + Next_page_script
  end


  def self.rad_bar
    res = <<-EOS
<div id="rad_bar">
  <button onclick='javascript:document.forms["rads"].submit();'>検索</button>
  <button id='rad_bar_hareru' onclick='javascript:rad_bar_clear();'>晴れる</button>
</div>
EOS
    res + Rad_bar_style + Rad_bar_script
  end
end
