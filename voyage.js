function voyage_handle_start(event) {event.preventDefault();}
    
function voyage_handle_end(event) {
  event.preventDefault();

  editLink = document.createElement("a");
  linkText = document.createTextNode("edit");

  editLink.setAttribute("href", "javascript:editNote('"+thisId+"')");
}

function voyage_scroll_hdl(event) {
  document.getElementById( 'voyage' ).style.top = window.innerHeight - 60  + window.scrollY;
};

function show(o)
{
  res = '';
  for(var key in o) {
    res += key + ':' + o[key] + "\n";
  }
    
  alert( res );
}

function voyage()
{
  var main = document.getElementById( 'voyage' );
  main.addEventListener("touchstart", voyage_handle_start, false);
  main.addEventListener("touchend", voyage_handle_end, false);
  main.appendChild( document.createTextNode( '旅' ) );
  
  document.addEventListener("scroll", voyage_scroll_hdl, false );
};

window.addEventListener("voyage", load, false);

