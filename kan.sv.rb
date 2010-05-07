class Kan
  def execute request
    kan = request[1]

    kan = kan.url_utf8 unless kan.is_num

    kanji = Kanji.new( kan )
    kid = kanji.kid.to_i
    res = Iphone::glisse( '/kan/', kid+10, kid-10, kid-1, kid+1 ) + kanji.to_html
    
    kan_lists = kanji.lists

    KList.lists.each do |list|
      kl,sleepy = kan_lists.find {|kl,sleepy| kl.lid == list.lid}
      if kl
        res << "<br/><a href='/lists/hib/#{list.lid}/#{kanji.kid}'>#{ sleepy ? 'un' : '' }hibernate in #{list.name}</a>"
      else
        res << "<br/><a href='/lists/add/#{list.lid}/#{kanji.kid}'>add to #{list.name}</a>"
      end
    end

    res + "<br/><br/><a href='/lists/add/new/#{kanji.kid}'>add to new</a><br/><br/>" + kanji.radicals + Iphone::voyage()
  end
end
