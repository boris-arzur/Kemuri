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

class Lists
  def self.create( request )
    if !request[2]
      add_option = request[:add] ? "+'?add=#{request[:add]}'" : ''
      <<-EOP
<input type="text" onchange="go_to( '/lists/create/'+document.getElementById( 'list_name' ).value#{add_option} )" id="list_name"/>
EOP
    elsif request[2].size > 0 && request[3] != "y"
      request[3] = "y"
      "create '#{@confirm_create}' ?".a request.to_url
    elsif request[2].size > 0 && request[3] == "y" 
      r = "INSERT INTO lists VALUES('#{@confirm_create}')"
      $db.execute( r )
      'create ok ' + Lists::redir_add( request )
    else
      'invalid'
    end
  end

  def self.redir_add( request )
    return '' unless request['add']
    lid = $db.get_first_value( 'SELECT last_insert_rowid()' )
    Lists::add( Request.new( 'GET', [nil,nil,lid,request['add']], {}, nil ) )
  end
  
  def self.add( request )
    if request[2] == "new"
      Lists::create( Request.new( 'GET', [], {:add => request[3]}, nil ) )
    elsif request[2].is_num
      if request[3].is_num
        r = "INSERT OR IGNORE INTO kan2list (kid,lid) VALUES(#{request[3]},#{request[2]});"
        $db.execute( r )
        'add ok'
      else
        'erreur de format pour path[3] (pas un kid)'
      end
    else
      'erreur de format pour path[2] (pas un lid)'
    end
  end

  def self.hib( request )
    KList.new( request[2] ).toggle_sleepy( Kanji.new( request[3] ) )
  end

  def execute request
    case request[1]
    when "create" then Lists::create( request )
    when "add" then Lists::add( request )
    when "hib" then Lists::hib( request )
    end
  end
end
