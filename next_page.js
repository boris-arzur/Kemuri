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

function append( xml ) {
  var newDiv = document.createElement( "div" );
  newDiv.innerHTML= xml;
  var add = document.getElementById( 'add' );
  /* add.innerHTML= add.innerHTML + xml; */
  add.appendChild( newDiv );
}

var ask_for = 'p=';
function next_page_scroll_hdl( event ) {
  if( free_ajax && update && (window.scrollY + window.innerHeight >= 0.90 * document.getElementById( 'bottom' ).offsetTop) ) {
    /* glue is defined in static.rb */
    var url = next_page_url_base + glue + ask_for + next_page;
    ajax_get( url );
    /* content is appended by the eval */
  };
}

var free_ajax = true;
/* only ajax once */
function ajax_get( url ) {
  if( free_ajax ) {
    free_ajax = false;
    window.setTimeout(function(){free_ajax = true;}, 1500);
    var req = new XMLHttpRequest();
    req.open( "GET", url , false );
    /* req.overrideMimeType( "application/json" ); no need to force anymore, implemented server side */
    req.send( null );
    /* eval( req.responseText ); this -might be- -IS- WAS a security hole */
    json = JSON.parse( req.responseText );
    console.dir( json );
    append( json["content_as_html"] );
    if( json["fin"] ) finished();
    if( json["pairs"] ) do_pairs();
    next_page = json["last_row"];
    next_page_scroll_hdl( null );
    free_ajax = true;
  };
}

function finished() {
  update = false;
  append( " --- end of content --- " );
}

function do_pairs() { 
  update = true;
  ask_for = 'pairs=';
  next_page = 0;
  append( " --- pairs --- <br/>" );
  next_page_scroll_hdl( null );
}

function do_alt() { 
  update = true;
  ask_for = 'alt&pairs=';
  next_page = 0;
  append( " --- alt pairs --- <br/>" );
  next_page_scroll_hdl( null );
}

function do_fuzz() { 
  update = true;
  ask_for = 'fuzz&p=';
  next_page = 0;
  append( " --- fuzz --- <br/>" );
  next_page_scroll_hdl( null );
}

document.addEventListener( "scroll", next_page_scroll_hdl, false );
next_page_scroll_hdl( null );

