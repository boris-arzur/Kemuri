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

require 'sqlite3'
require './backstore_handling.rb'

$db = SQLite3::Database.new( "iphone.db" )
$db.execute( "CREATE TABLE IF NOT EXISTS annexes (kid INT, yaml TEXT, UNIQUE(kid) );" )
=begin
$db.execute( "SELECT name FROM lists" ).each do |name|
  name = name[0]
  next if name =~ /-sleeping$/
  $db.execute( "INSERT OR IGNORE INTO lists VALUES( '#{name}-sleeping' )" )
end
=end
