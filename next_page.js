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

var req;
function next_page_scroll_hdl(event) {
    if( window.scrollY + window.innerHeight >= next_page_limit ) {
	req = new XMLHttpRequest();
	var url = next_page_url_base +'p='+ next_page;
	req.open( "GET", url , false );
	req.onreadystatechange = function() {
	    window.setTimeout(function () {
		    var add = document.getElementById( 'add' );
		    add.innerHTML= add.innerHTML + req.responseText;
		}, 100);
	};
	req.send(null);
	next_page = next_page + 1;
    };
};

var next_page_limit = document.getElementById( 'bottom' ).offsetTop;
var next_page = 1;
document.addEventListener( "scroll", next_page_scroll_hdl, false );
