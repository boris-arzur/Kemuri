var glisse_begin_x = 0, glisse_begin_y = 0;

function glisse_handle_start(event) {
  event.preventDefault();

  glisse_begin_x = event.targetTouches[0].clientX;
  glisse_begin_y = event.targetTouches[0].clientY;
}
    
function glisse_handle_move(event) {
  event.preventDefault();

  var data = document.getElementById( 'glisse' );
  var dx = event.targetTouches[0].clientX - glisse_begin_x;
  var dy = event.targetTouches[0].clientY - glisse_begin_y;
  
  var dir = '';
  
  if(Math.abs( dx ) < 15 && Math.abs( dy ) < 15) {
    dir = '[X]';
  } else if(Math.abs( dx ) > Math.abs( dy )) {
    if( dx > 0 ) dir = glisse_right;
    else dir = glisse_left;
  } else {
    if( dy > 0 ) dir = glisse_up;
    else dir = glisse_down;
  };
  
  while( data.firstChild ) data.removeChild( data.firstChild );
  data.appendChild( document.createTextNode( dir ) );
}

function glisse_handle_end(event) {
  event.preventDefault();
  
  var end_p = document.getElementById( 'glisse' ).firstChild.data;
  if(end_p == '[X]') return false;
  window.location = glisse_base + end_p;
}

function glisse_scroll_hdl(event) {
  document.getElementById( 'glisse' ).style.top = window.innerHeight - 75  + window.scrollY;
};

function show(o)
{
  res = '';
  for(var key in o) {
    res += key + ':' + o[key] + "\n";
  }
    
  alert( res );
}

var glisse_base, glisse_left, glisse_right, glisse_up, glisse_down;

function glisse(base, up, down, left, right)
{
  var main = document.getElementById( 'glisse' );
  main.addEventListener("touchstart", glisse_handle_start, false);
  main.addEventListener("touchmove", glisse_handle_move, false);
  main.addEventListener("touchend", glisse_handle_end, false);
  main.appendChild( document.createTextNode( '' ) );
  
  document.addEventListener("scroll", glisse_scroll_hdl, false );
    
  glisse_base = base;
  glisse_left = left;
  glisse_right = right;
  glisse_up = up;
  glisse_down = down;
};


