function voyage_focus_input( event ) {
    document.getElementById( 'voyage' ).style.opacity = "1.0";
};

function voyage_create_option( nani ) {
    var option = document.createElement( 'option' );
    option.setAttribute( 'value', nani );
    option.appendChild( document.createTextNode( nani ) );
    return option;
};

function voyage_update_options() {
    var dokomade = document.getElementById( 'dokomade' ).value;
    if( dokomade.size != 0) {
	var select = document.createElement( 'select' );
	select.setAttribute( 'id', 'douyatte' );
	var direct_commit = false;

	if( dokomade.match(/^\d-\d+-\d+$/) ) {
	    select.appendChild( voyage_create_option( '/sk/' ) );
	    direct_commit = true;
	} else if( dokomade.match(/^[\u4E00-\u9FAF]$/) ) {
	    select.appendChild( voyage_create_option( '/yad/' ) );
	    select.appendChild( voyage_create_option( '/kan/' ) );
	} else if( dokomade.match(/^[\u4E00-\u9FAF]+$/) || dokomade.match(/^[\u3040-\u3096]+$/) ) {
	    select.appendChild( voyage_create_option( '/yad/' ) );
	    direct_commit = true;
	} else {
	    select.appendChild( voyage_create_option( '/yad/' ) );
	    direct_commit = true;
	}
	
	select.firstChild.setAttribute( 'selected', 'selected' );
	select.setAttribute( 'onchange', 'javascript:voyage_shuppatsu()' );
	voyage_placeholder.appendChild( select );
	
	if( direct_commit )
	    voyage_shuppatsu();
	else {
	    var go_btn = document.createElement( 'input' );
	    go_btn.setAttribute( 'type', 'button' );
	    go_btn.setAttribute( 'value', '出発' );
	    go_btn.setAttribute( 'onclick', 'javascript:voyage_shuppatsu()' );
	    voyage_placeholder.appendChild( go_btn );
	    voyage_scroll_offset = 70;
	    voyage_scroll_hdl(null);
	}
    }
};

function voyage_shuppatsu() {
    var dokomade = document.getElementById( 'dokomade' ).value;
    var douyatte = document.getElementById( 'douyatte' );
    var path = douyatte.options[douyatte.selectedIndex].value; 
    window.location = path + dokomade;
};

function voyage_scroll_hdl(event) {
  document.getElementById( 'voyage' ).style.top = window.innerHeight - voyage_scroll_offset + window.scrollY;
};

var voyage_scroll_offset = 40;
var voyage_placeholder = document.getElementById( 'voyage' );
document.addEventListener("scroll", voyage_scroll_hdl, false );
voyage_placeholder.style.left = 220;