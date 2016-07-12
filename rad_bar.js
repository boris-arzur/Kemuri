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

  window.location = "/rad/"+rads.join( "/" );
}
