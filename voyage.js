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
        else if( dokomade.match(/\+|&/) )
            destination = '/slook/';
        else
            destination = '/yad/';
        
        window.location = destination + dokomade;
   };
};

addEventListener("load", function(){ 
    document.getElementById( 'content' ).style.marginTop= document.getElementsByClassName('bar')[0].offsetHeight;
    document.getElementById( 'content' ).style.width= '100%';
}, false);
