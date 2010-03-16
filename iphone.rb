class Iphone
  Glisse_style = File::read( 'glisse.css' ).style
  Glisse_script = File::read( 'glisse.js' ).script

  Voyage_style = File::read( 'voyage.css' ).style
  Voyage_script = File::read( 'voyage.js' ).script

  Next_page_script =  File::read( 'next_page.js' ).script

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
       value="" size=10/>
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
end
