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

class Kan
  def execute request
    kan = request[1]

    kan = kan.url_utf8 unless kan.is_num

    kanji = Kanji.new( kan )
    kid = kanji.kid.to_i
    to_history( '/kan/' + kanji.kanji )

    res = Static::glisse( '/kan/', kid+10, kid-10, kid-1, kid+1 ) + kanji.to_html
    
    kan_lists = kanji.lists

    KList.lists.each do |list|
      kl,sleepy = kan_lists.find {|kl,sleepy| kl.lid == list.lid}
      if kl
        res << "<br/><a href='/lists/hib/#{list.lid}/#{kanji.kid}'>#{ sleepy ? 'un' : '' }hibernate in #{list.name}</a>"
      else
        res << "<br/><a href='/lists/add/#{list.lid}/#{kanji.kid}'>add to #{list.name}</a>"
      end
    end

    res + "<br/><br/><a href='/lists/add/new/#{kanji.kid}'>add to new</a><br/><br/>" + kanji.radicals + Static::voyage
  end
end
