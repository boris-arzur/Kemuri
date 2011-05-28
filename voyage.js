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

function voyage_focus_input( event ) {
    voyage_placeholder.style.opacity = "1.0";
    do_move = false;
    if( typeof( rad_bar_placeholder ) != "undefined" )
        rad_bar_placeholder.style.opacity = "0.0";
    if( typeof( yad_bar_placeholder ) != "undefined" )
        yad_bar_placeholder.style.opacity = "0.0";
    document.getElementById( 'voyage_btns' ).style.display = "block";
};

function voyage_blur_input( event ) {
    /* we need the timeout to be able to click on the buttons, tricky ... */
    window.setTimeout(function() {
      voyage_placeholder.style.opacity = "0.3";
      do_move = true;
      if( typeof( rad_bar_placeholder ) != "undefined" )
          rad_bar_placeholder.style.opacity = "1.0";
      if( typeof( yad_bar_placeholder ) != "undefined" )
          yad_bar_placeholder.style.opacity = "1.0";
      document.getElementById( 'voyage_btns' ).style.display = "none";
    }, 30);
};

function voyage_update_options() {
    var dokomade = document.getElementById( 'dokomade' ).value;
    var destination = '/yad/';
    if( dokomade.size != 0) {
        if( dokomade.match(/^\d-\d+-\d+$/) || dokomade.match(/^\d+$/) )
            destination = '/sk/';
        else if( dokomade.match(/^\d-\d+-\d+\+\d-\d+-\d+$/) )
            destination = '/biskip/';
        else if( dokomade.match(/^\d+-\d+$/) || dokomade.match(/^\d-\d+-\d+-\d-\d+-\d+$/) )
            destination = '/sk/';
        else if( dokomade.match(/^http/) )
            destination = '/proxy/';
        else if( dokomade.match(/:|&/) )
            destination = '/slook/';
        else
            destination = '/yad/';
        
        go_to( destination + dokomade );
   } else {
        voyage_blur_input( null );
   }
};

function voyage_scroll_hdl(event) {
  if( do_move ) {
    voyage_placeholder.style.top = window.innerHeight - voyage_scroll_offset + window.scrollY;
  }
};

var do_move = true;
var voyage_scroll_offset = 40;
var voyage_placeholder = document.getElementById( 'voyage' );
document.addEventListener( "scroll", voyage_scroll_hdl, false );
voyage_placeholder.addEventListener( "change", voyage_update_options, false );
voyage_placeholder.addEventListener( "focus", voyage_focus_input, true );
voyage_placeholder.addEventListener( "blur", voyage_blur_input, true );

voyage_placeholder.style.left = 220;
window.addEventListener( "load", function(){window.setTimeout(function(){voyage_scroll_hdl( null );}, 50);}, false);
