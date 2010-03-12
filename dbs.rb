require 'sqlite3'
require 'backstore_handling.rb'

$db = SQLite3::Database.new( "iphone.db" )
$db.execute( "CREATE TABLE IF NOT EXISTS annexes (kid INT, yaml TEXT, UNIQUE(kid) );" )
=begin
$db.execute( "SELECT name FROM lists" ).each do |name|
  name = name[0]
  next if name =~ /-sleeping$/
  $db.execute( "INSERT OR IGNORE INTO lists VALUES( '#{name}-sleeping' )" )
end
=end
