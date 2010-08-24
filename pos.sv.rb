#    Copyright 2008, 2009, 2010 Boris ARZUR
#
#    This file is part of Kemuri.
#
#    Kemuri is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of
#    the License, or (at your option) any later version.
#
#    Kemuri is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public
#    License along with Kemuri. If not, see http://www.gnu.org/licenses.

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
       var pos = "https://your_url/path/null?lat=" +lat+ "&long=" +long+ "&ip=#{ip}";
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
