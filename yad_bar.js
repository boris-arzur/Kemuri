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

function yad_bar_scroll_hdl(event) {
    yad_bar_placeholder.style.top = window.innerHeight - yad_bar_scroll_offset + window.scrollY;
}

function yad_bar_clear() {
    var chkbxz = document.forms["rads"].elements;
    for (i = 0; i < chkbxz.length; i++)
        chkbxz[i].checked = false;
    return false;
}

var yad_bar_scroll_offset = 90;
var yad_bar_placeholder = document.getElementById( "yad_bar" );
document.addEventListener( "scroll", yad_bar_scroll_hdl, false );
yad_bar_placeholder.style.left = 220;
yad_bar_scroll_hdl(null);
