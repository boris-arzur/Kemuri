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

function got_clicked( event ) {
    var url = event.target.href.split( "/" );
    alert( url[3] );
    if( !url[3].match( /xml$/ ) )
      url[3] = url[3] + '.xml';
    
    var req = new XMLHttpRequest();
    req.open( "GET", url.join( "/" ), false );
    req.overrideMimeType( "text/html" );
    req.send( null );
    document.getElementsByTagName('body')[0].innerHTML= req.responseText;
    register_click_handlers();
    return false;
}

function register_click_handlers() {
    var linkArray = document.getElementsByTagName( 'a' );
    for (i = 0; i < linkArray.length; i++)
        linkArray[i].onclick = got_clicked;
}

register_click_handlers(); 
