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
    return KList.lists.map {|list| list.name.a( "/yav/?lid=#{list.lid}" ) }*'<br/>' unless @list || request['lid']

    @list = KList.new( request['lid'] ) if request['lid']

    case request[1]
    when 'y' then @kanjis.delete( @kanji ); @step = 0
    when 'n' then @step = 0
    when 'h' then @list.toggle_sleepy( @kanji ); @kanjis.delete( @kanji ); @step = 0
    end

    Pool_size.times do @kanjis << @list.next_kanji end if @kanjis.size == 0

    @kanji = @kanjis.sort_by {rand}[0] if @step == 0

    le_bubun = if @step < 2
                 Static::glisse( '/yav/', '', '', '', '', '' )
               else
                 Static::glisse( '/yav/', 'n', 'h', 'n', 'y', '' )
               end

    reply = le_bubun + @kanji.to_html( @step )#.a( link ) #+ Style
    @step += 1
    reply + Static::voyage
  end
end

