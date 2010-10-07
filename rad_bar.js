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

function rad_bar_scroll_hdl(event) {
    rad_bar_placeholder.style.top = window.innerHeight - rad_bar_scroll_offset + window.scrollY;
}

function rad_bar_clear() {
    var chkbxz = document.forms["rads"].elements;
    for (i = 0; i < chkbxz.length; i++)
        chkbxz[i].checked = false;
    return false;
}

function send_form() {
  var rads = new Array();
  var chkbxz = document.forms["rads"].elements;

  for (i = 0; i < chkbxz.length; i++)
       if( chkbxz[i].checked )
           rads.unshift( chkbxz[i].value );

  go_to( "/rad/?rad="+rads.join( "&rad=" ) );
}

var rad_bar_scroll_offset = 65;
var rad_bar_placeholder = document.getElementById( "rad_bar" );
document.addEventListener( "scroll", rad_bar_scroll_hdl, false );
rad_bar_placeholder.style.left = 220;
rad_bar_scroll_hdl(null);
