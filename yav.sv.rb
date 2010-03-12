#Style = "td{font-size:2em;}".tag( 'style','type'=>'text/css')
Pool_size = 5

class Yav
  def initialize
    @list = nil
    @kanjis = []
    @kanji = []
    @step = 0
  end

  def execute request
    return KList.lists.map {|list| list.name.a( '/yav/?lid='+list.lid ) }*'<br/>' unless @list || request['lid']

    @list = KList.new( request['lid'] ) if request['lid']

    case request[1]
    when 'y' : @kanjis.delete( @kanji ); @step = 0
    when 'n' : @step = 0
    when 'h' : @list.toggle_sleepy( @kanji ); @kanjis.delete( @kanji ); @step = 0
    end

    Pool_size.times do @kanjis << @list.next_kanji end if @kanjis.size == 0

    @kanji = @kanjis.sort_by {rand}[0] if @step == 0

    le_bubun,link = if @step < 2
                      [touch( '/yav/', '', '', '', '' ),'/yav/']
                    else
                      [touch( '/yav/', 'n', 'y', 'y', 'h' ),'/yav/y']
                    end

    reply = le_bubun + @kanji.to_html( @step ).a( link ) #+ Style
    @step += 1
    reply
  end
end

