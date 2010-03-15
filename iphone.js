var touch_begin_x = 0, touch_begin_y = 0;

function handle_start(event)
{
    event.preventDefault();

    touch_begin_x = event.targetTouches[0].clientX;
    touch_begin_y = event.targetTouches[0].clientY;
}
    
function handle_move(event)
{
    event.preventDefault();

    var data = document.getElementById( 'touch-main' );
    var dx = event.targetTouches[0].clientX - touch_begin_x;
    var dy = event.targetTouches[0].clientY - touch_begin_y;

    var dir = '';

    if (Math.abs( dx ) < 15 && Math.abs( dy ) < 15)
    {
        dir = '[X]';
    }
    else if (Math.abs( dx ) > Math.abs( dy ))
    {
	if( dx > 0 ) dir = touch_right;
	else dir = touch_left;
    }
    else
    {
        if( dy > 0 ) dir = touch_up;
        else dir = touch_down;
    };

    while( data.firstChild ) data.removeChild( data.firstChild );
    data.appendChild( document.createTextNode( dir ) );
}


function handle_end(event)
{
    event.preventDefault();
    
    var end_p = document.getElementById( 'touch-main' ).firstChild.data;
    if (end_p == '[X]') return false;
    window.location = touch_base + end_p;
}


function scroll_hdl(event)
{
    document.getElementById( 'touch-main' ).style.top = window.innerHeight - 80  + window.scrollY;
};

function show(o)
{
    res = '';
    for (var key in o) {
        res += key + ':' + o[key] + "\n";
    }
    
    alert( res );
}


var touch_base, touch_left, touch_right, touch_up, touch_down;

function touch(base, left, right, up, down)
{
    var main = document.getElementById( 'touch-main' );
    main.addEventListener("touchstart", handle_start, false);
    main.addEventListener("touchmove", handle_move, false);
    main.addEventListener("touchend", handle_end, false);
    main.appendChild( document.createTextNode( '' ) );
    
    document.addEventListener("scroll", scroll_hdl, false );
    
    touch_base = base;
    touch_left  = left;
    touch_right = right;
    touch_up = up;
    touch_down = down;
    
    
    //show( document.getElementById( 'touch-main' ).style );
    //show( window );
    window.setTimeout("window.scrollTo(0, 1)", 500);
};


