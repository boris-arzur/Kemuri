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

class Log
  def initialize
    Static::add_hidden_button( 'l','log' )
    @last_visit = Time.now
  end

  def execute request
    now = Time.now
    content = $log_bf * "\n"

    if now - @last_visit < 5
      content += "\n--- filed logs ---\n\n"
      content += File::read( 'server.log' )
    end

    @last_visit = now
    content.escape.gsub( /\n/ , '<br/>' ) + Static::voyage
  end
end
