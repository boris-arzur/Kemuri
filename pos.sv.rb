class Pos
  def execute request
    update = (request[1] || 1800000).to_i

    ip = `sudo ifconfig`.split( "\n" ).find {|e| e =~ /inet/ && e !~ /127.0.0.1/ }.split[1]
    #ip = '127.0.0.1'
<<EOS
<script type="text/javascript">
(function() {
  function update_coords(){
     function success(position) {
       var lat = position.coords.latitude;
       var long = position.coords.longitude;
       var pos = "https://www.arzur.fr/wtf_pos_MDc3NDQ0NjMyNzgwOTU4NA/null?lat=" +lat+ "&long=" +long+ "&ip=#{ip}";
       var req = new XMLHttpRequest();
       req.open("GET", pos, false);
       req.send(null);
     };
     
     function error(error) {
     };


     navigator.geolocation.getCurrentPosition( success, error, {enableHighAccuracy:true,maximumAge:600000} );
   };

  update_coords();
  window.setInterval( update_coords, #{update} );
})();
</script>
EOS
  end
end
