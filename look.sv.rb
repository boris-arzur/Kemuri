# encoding: UTF-8
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

class Look 
  @@mutex = Mutex.new
  @@store = {}

  def execute request
    Look::process request
  end

  def self.start( data )
    log "starting with this : " +data.inspect
    id = (rand * 1_000_000_000).to_i
    @@mutex.synchronize {@@store[id] = data}
    req_rewrite = Request.new( false, ['look',id], {}, nil )
    Look::process req_rewrite
  end

  def self.process request
    id = request[1].to_i
    data = @@store[id]

    unless request.type
      radicals_pickup = data.map {|ele| 
        ele[:r].map {|kan| 
          [kan.style( 'color:green' ),"&rarr;"]+Kanji.new( kan ).get_radicals.map {|i,e| "<input type='checkbox' name='r#{kan.hash}' value='#{i}'/>#{e}"}
        }
      }.flatten( 1 )
      
      radicals_pickup << ["<input type=submit value=ok />"]
      radicals_pickup = radicals_pickup.to_table( :td_opts => {:style=>'font-size:3em'} )
      radicals_pickup.tag( "form", :action => request.to_url, :method => "post" )
    else
      #no d'etape ?
      data.each do |ele|
        ele[:r].map! {|kan| request.post["r#{kan.hash}"]}
      end
    end
  end
end
