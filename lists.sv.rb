class Lists
  def initialize
    @confirm_create = ''
  end

  def create( request )
    if !request[2]
      @confirm_create = ''
      add_option = request[:add] ? "+'?add=#{request[:add]}'" : ''
<<EOP
<input type="text" onchange="javascript:window.location='/lists/create/'+document.getElementById( 'list_name' ).value#{add_option}" id="list_name"/>
EOP
    elsif request[2].size > 0 && @confirm_create != request[2]
      @confirm_create = request[2]
      "create '#{@confirm_create}' ?".a request.to_url
    elsif @confirm_create == request[2]
      r = "INSERT INTO lists VALUES('#{@confirm_create}')"
      $db.execute( r )
      'create ok ' + redir_add( request )
    else
      'invalid'
    end
  end

  def redir_add( request )
    return '' unless request['add']
    lid = $db.get_first_value( 'SELECT last_insert_rowid()' )
    add( Request.new( [nil,nil,lid,request['add']], {} ) )
  end
  
  def add( request )
    if request[2] == "new"
      create( Request.new( [], :add => request[3] ) )
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

  def hib( request )
    KList.new( request[2] ).toggle_sleepy( Kanji.new( request[3] ) )
  end

  def execute request
    case request[1]
    when "create" : create( request )
    when "add" : add( request )
    when "hib" : hib( request )
    end
  end
end
