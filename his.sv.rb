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

class His
  def initialize
    Static::add_hidden_button( 'h','his' )
    @last_visit = Time.now
  end

  def execute request
    content = Hash.new do |h,k| h[k] = 0 end
    limit = 100
    now = Time.now

    if now - @last_visit < 5
      limit = 1000000
    else
      message 'speedup : partial history processed'
    end

    @last_visit = now

    history_file = `tail -n #{limit} history.log`.split( "\n" ).each do |l|
      content[l] += 1
    end

    content.map {|l,num|
      name = l.gsub( /^\/(kan|yad)\// ) {"#{$1}: "}.gsub( /%E.%..%../ ) {|kanji| kanji.url_utf8}
      name += " # = #{num}"
      name.a( l ).td.tr
    }.reverse.table + Static::voyage + Static::search
  end
end
