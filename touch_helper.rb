style = File::read( 'iphone.css' ).style
script = File::read( 'iphone.js' ).script

def touch base,l1,l2,l3,l4
#<script type="text/javascript" charset="utf-8" src="http://127.0.0.1/iphone.js"></script>
#<link rel="stylesheet" href="http://127.0.0.1/iphone.css" type="text/css" charset="utf-8"/>
style + script + <<EOS
<script type="text/javascript" charset="utf-8">
function load() { touch( '#{base}','#{l1}','#{l2}','#{l3}','#{l4}'); };
window.addEventListener("load", load, false);
</script>
<div class="touch-main"></div>
EOS
end
