function append( content ) {
  var add = document.getElementById( 'content' );
  add.innerHTML= add.innerHTML + content;
}

var ask_for = 'p=';
function next_page_scroll_hdl( event ) {
  if( free_ajax && update && (window.scrollY + window.innerHeight >= 0.90 * document.getElementById( 'bottom' ).offsetTop) ) {
    /* glue is defined in static.rb */
    var url = next_page_url_base + glue + ask_for + next_page;
    ajax_get( url );
  };
}

function processData(data) {
  json = JSON.parse( data );
  append( json["content_as_html"] );
  if( json["fin"] ) finished();
  if( json["pairs"] ) do_pairs();
  next_page = json["last_row"];
  free_ajax = true;
  next_page_scroll_hdl( null );
}

function handler() {
  if(this.status == 200) {
    processData(this.responseText);
  } else {
    alert("failed ajax");
  }
}
var free_ajax = true;
function ajax_get( url ) {
  if( free_ajax ) {
    free_ajax = false;
    window.setTimeout(function(){free_ajax = true;}, 1500);
    var client = new XMLHttpRequest();
    client.onload = handler;
    client.open("GET", url);
    client.send();
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
