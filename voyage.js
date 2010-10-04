/*
    Copyright 2008, 2009, 2010 Boris ARZUR

    This file is part of Kemuri.

    Kemuri is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Kemuri is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public
    License along with Kemuri. If not, see http://www.gnu.org/licenses.
*/

var do_move = true;
function voyage_focus_input( event ) {
    voyage_placeholder.style.opacity = "1.0";
    do_move = false;
    if( typeof( rad_bar_placeholder ) != "undefined" )
        rad_bar_placeholder.style.opacity = "0.0";
    document.getElementById( 'voyage_btns' ).style.display = "inline";
};

function voyage_blur_input( event ) {
    voyage_placeholder.style.opacity = "0.3";
    do_move = true;
    if( typeof( rad_bar_placeholder ) != "undefined" )
        rad_bar_placeholder.style.opacity = "1.0";
    document.getElementById( 'voyage_btns' ).style.display = "hidden";
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
        voyage_placeholder.appendChild( document.createElement( 'br' ) );
        
        var select = document.createElement( 'select' );
        select.setAttribute( 'id', 'douyatte' );
        var direct_commit = true;

        if( dokomade.match(/^\d-\d+-\d+$/) || dokomade.match(/^\d+$/) )
            select.appendChild( voyage_create_option( '/sk/' ) );
        else if( dokomade.match(/^\d-\d+-\d+\+\d-\d+-\d+$/) )
            select.appendChild( voyage_create_option( '/biskip/' ) );
        else if( dokomade.match(/^\d+-\d+$/) || dokomade.match(/^\d-\d+-\d+-\d-\d+-\d+$/) )
            select.appendChild( voyage_create_option( '/sk/' ) );
        else if( dokomade.match(/^rad$/) || dokomade.match(/^his$/) )
            select.appendChild( voyage_create_option( '/' ) );
    	else if( dokomade.match(/^[\u4E00-\u9FAF]$/) ) {
            select.appendChild( voyage_create_option( '/yad/' ) );
            /*
              since we link to kan at the first line, I think we can remove that :
              select.appendChild( voyage_create_option( '/kan/' ) );
              direct_commit = false;
            */
    	} 
        else if( dokomade.match(/^[\u4E00-\u9FAF]+$/) || dokomade.match(/^[\u3040-\u3096]+$/) ) 
            select.appendChild( voyage_create_option( '/yad/' ) );
    	else select.appendChild( voyage_create_option( '/yad/' ) );
    		
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
            voyage_scroll_hdl( null );
    	}
   } else {
        voyage_blur_input( null );
   }
};

function voyage_shuppatsu() {
    var dokomade = document.getElementById( 'dokomade' ).value;
    var douyatte = document.getElementById( 'douyatte' );
    var path = douyatte.options[douyatte.selectedIndex].value; 
    window.location = path + dokomade;
};

function voyage_scroll_hdl(event) {
  if( do_move ) {
    voyage_placeholder.style.top = window.innerHeight - voyage_scroll_offset + window.scrollY;
  }
};

var voyage_scroll_offset = 40;
var voyage_placeholder = document.getElementById( 'voyage' );
document.addEventListener( "scroll", voyage_scroll_hdl, false );
voyage_placeholder.addEventListener( "change", voyage_update_options, false );
voyage_placeholder.addEventListener( "focus", voyage_focus_input, true );
voyage_placeholder.addEventListener( "blur", voyage_blur_input, true );

voyage_placeholder.style.left = 220;
