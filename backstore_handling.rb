=begin
kanjis(kanji TEXT, readings TEXT, meanings TEXT, skip TEXT, forder INT )
radicals(radical TEXT, strokes INT)
examples(japanese TEXT, english INT)
lists(name TEXT)
annex(kid INT, yaml TEXT)

kan2list(kid INT, lid INT, sleepy def false)
kan2rad(kid INT, rid INT)
=end

class Kanji
  attr_accessor :kid, :kanji, :readings, :meanings, :skip, :forder

  def initialize( kid_or_kanji )
    if kid_or_kanji.is_num
      @kid = kid_or_kanji
      r = "SELECT kanji,readings,meanings,skip,forder FROM kanjis WHERE oid = #{@kid}"
      @kanji, @readings, @meanings, @skip, @forder = $db.get_first_row( r )
    else
      @kanji = kid_or_kanji
      r = "SELECT oid,readings,meanings,skip,forder FROM kanjis WHERE kanji = '#{@kanji}'"
      @kid, @readings, @meanings, @skip, @forder = $db.get_first_row( r )
    end
    @forder = @forder.to_i
    @annex = nil
    @lists = nil
  end

  def annex
    return @annex if @annex
    r = "SELECT yaml FROM annexes WHERE kid = #{@kid}"
    yaml = $db.get_first_value( r )
    @annex = yaml ? YAML.load( yaml ) : {}
  end

  def radicals
    r2 = "SELECT radicals.oid,radicals.radical FROM (SELECT rid FROM kan2rad WHERE kid = #{@kid}) AS rids LEFT JOIN radicals ON rids.rid = radicals.oid;"
    $db.execute( r2 ).map {|i,e| e.a( '/rad/'+i )} * " "
  end

  def to_row
    [@kanji,@readings,@meanings].to_row
  end

  def to_html( i = 999 )
    #ajouter de la couleur
    color = 'color:' + if @forder == 0
                         'black'
                       elsif @forder < 1000
                         'green'
                       elsif @forder < 2000
                         'blue'
                       elsif @forder < 3000
                         'orange'
                       else
                         'red'
                       end

    res = [[@kanji.style( color )]]
    res << [@meanings] if i > 0
    res << [@readings] if i > 1
    res << [@skip.a( '/sk/'+@skip )] << [@forder.to_s] if i > 990 and @skip
    
    #ajouter lien pour mettre ds liste
    return res.to_table
  end

  def save_annex
    yaml = YAML.dump( annex )
    r = "REPLACE INTO annexes VALUES(#{@kid},'#{yaml}')"
    $db.execute( r )
  end
  
  def lists
    return @lists if @lists
    r = "SELECT lid,sleepy FROM kan2list WHERE kid = #{@kid}"
    @lists = $db.execute( r ).map {|lid,sleepy| [KList.new( lid ), sleepy.to_i == 1]}
  end

  def delete_from( list )
    r = "DELETE FROM kan2list WHERE kid = #{@kid} AND lid = #{list.lid};"
    $db.execute( r )
  end
end

class KList
  def self.lists
    r = "SELECT oid,name FROM lists"
    $db.execute( r ).map {|oid,name| KList.new( oid, name)}
  end

  attr_accessor :lid, :name, :idx

  def initialize( lid_or_name, name = nil )
    if !name
      if lid_or_name.is_num
        @lid = lid_or_name
        r = "SELECT name FROM lists WHERE oid = #{@lid}"
        @name = $db.get_first_value( r )
      else
        @name = lid_or_name
        r = "SELECT oid FROM lists WHERE name = '#{@name}'"
        @lid = $db.get_first_value( r )
      end
    else
      @lid = lid_or_name
      @name = name
    end

    @idx = 0
  end

  def kids
    return @kids if @kids
    r = "SELECT kid FROM kan2list WHERE lid = #{@lid} and sleepy != 1 ORDER BY random()"
    @kids = $db.execute( r ).map{|kid| kid[0]}
  end

  def all_kids
    return @all_kids if @all_kids
    r = "SELECT kid FROM kan2list WHERE lid = #{@lid} ORDER BY random()"
    @all_kids = $db.execute( r ).map{|kid| kid[0]}
  end
  
  def toggle_sleepy( kanji )
    r = "SELECT sleepy FROM kan2list WHERE lid = #{@lid} and kid = #{kanji.kid}"
    status = ($db.get_first_value( r ).to_i - 1) % 2 #fait le toggle en mm tps
    r = "REPLACE INTO kan2list VALUES( #{kanji.kid} , #{@lid} , #{status} )"
    $db.execute( r )
    'ok'
  end

  def next_kanji
    k = Kanji.new( kids[@idx] )
    @idx += 1
    k
  end
end
