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
  def execute request
    content = File::read( 'history.log' ).split( "\n" )
    content.sort.uniq.map {|l| 
      name = l.gsub( /^\/(.)(an|ad)\// ) {"#{$1} "}.gsub( /%E.%..%../ ) {|kanji| kanji.url_utf8}
      name.a( l ).tag( 'td' ).tag( 'tr' )
    }.join.tag( 'table' ) + Iphone::voyage
  end
end
