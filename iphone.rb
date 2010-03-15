class Iphone
  Glisse_style = File::read( 'glisse.css' ).style
  Glisse_script = File::read( 'glisse.js' ).script

  Voyage_style = File::read( 'voyage.css' ).style
  Voyage_script = File::read( 'voyage.js' ).script

  def glisse( url_base, haut, bas, gauche, droite )
#<script type="text/javascript" charset="utf-8" src="http://127.0.0.1/iphone.js"></script>
#<link rel="stylesheet" href="http://127.0.0.1/iphone.css" type="text/css" charset="utf-8"/>
<<EOS
<script type="text/javascript" charset="utf-8">
function load() { glisse( '#{url_base}','#{haut}','#{bas}','#{gauche}','#{droite}'); };
window.addEventListener("load", load, false);
</script>
<div id="glisse"></div>
EOS + Glisse_style + Glisse_script
  end

  def voyage
    "<div id=\"voyage\"></div>" + Voyage_style + Voyage_script
  end
end
