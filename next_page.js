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

var end_of_content = false;
function append_html( text ) {
  var add = document.getElementById( 'add' );
  add.innerHTML= add.innerHTML + text;
}

var ask_for = 'p=';

var next_page = 1;
function next_page_scroll_hdl( event ) {
  if( (window.scrollY + window.innerHeight >= document.getElementById( 'bottom' ).offsetTop) && !end_of_content ) {
    var req = new XMLHttpRequest();
    //glue is defined in iphone.rb
    var url = next_page_url_base + glue + ask_for + next_page;
    req.open( "GET", url , false );
    req.overrideMimeType( "text/javascript" );
    req.send( null );
    next_page = next_page + 1;
    eval( req.responseText );
    /* content is appended by the eval */
    next_page_scroll_hdl( null );
  };
}

function finished() {
  end_of_content = true;
  append_html( " --- end of content --- " );
}

function do_pairs() {
  ask_for = 'pairs=';
  next_page = 0;
  append_html( " --- pairs --- <br/>" );
}

document.addEventListener( "scroll", next_page_scroll_hdl, false );
next_page_scroll_hdl( null );

