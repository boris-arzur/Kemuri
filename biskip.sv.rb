#coding:utf-8
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

=begin
    ----------- lent ----------------
    r_matches = matches_for( r_sk ).map{|k| "japanese LIKE '%#{k}%'"}*' OR '
    l_matches = matches_for( l_sk ).map{|k| "japanese LIKE '%#{k}%'"}*' OR '

    cond = '('+r_matches+') AND ('+l_matches+')'
    
    log( r = "SELECT * FROM examples WHERE #{cond}" )
    ------------ trop lent ------------
hors de Biskip

$sqlite_regexp = //

$db.create_function('regexp', 2 ) do |func, pattern, expression|
#  regexp = Regexp.new(pattern.to_s, Regexp::IGNORECASE)
  func.result = expression.to_s.match($sqlite_regexp) ? 1 : 0
end

dans Biskip
    r_matches = matches_for( r_sk )*'|' 
    l_matches = matches_for( l_sk )*'|'

    log ( $sqlite_regexp = Regexp.new( "(#{r_matches})(#{l_matches})" ) ).inspect

    r = "SELECT * FROM examples WHERE japanese REGEXP ''"
    ------------ trop profond ---------

    r_matches = matches_for( r_sk ) 
    l_matches = matches_for( l_sk )

    cond = []

    r_matches.each do |kr|
      l_matches.each do |kl|
        cond << "japanese LIKE '%#{kr}#{kl}%'"
      end
    end

    log( r = "SELECT * FROM examples WHERE #{cond*' OR '}" )

=end

class Biskip
  def matches_for skip
    r = "SELECT kanji FROM kanjis WHERE skip = '#{skip}' ORDER BY forder DESC"
    $db.execute( r )
  end

  def execute request
    codes = request[1]
    return "biskip 災難 &rarr; 2-3-4+1-10-8" + Static::voyage unless codes

    r_sk,l_sk = codes.split( '+' )

    r_matches = matches_for( r_sk ).map{|k| "japanese LIKE '%#{k}%'"}*' OR '
    l_matches = matches_for( l_sk ).map{|k| "japanese LIKE '%#{k}%'"}*' OR '

    cond = '('+r_matches+') AND ('+l_matches+')'
    
    r = "SELECT * FROM examples WHERE #{cond}"
    $db.execute( r ).to_table + Static::voyage
  end
end
