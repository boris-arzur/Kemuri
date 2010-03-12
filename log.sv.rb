class Log
  def execute request
    File::read( 'server.log' ).escape.gsub( /\n/ , '<br/>' )
  end
end
