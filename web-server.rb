#!/usr/bin/env ruby
$KCODE = "U"

require "webrick"
load "./servlets.rb"

Servlets::register_all

class MasterServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET (request, response)
    response.status = 200
    path = request.path.split('/')[1..-1]
    query = request.query
    if path[0] =~ /\.xml$/
        path[0] = path[0][0..-5]
        query['xml'] = true
    end
    response.body = Servlets::execute(request, path, query, response)
    response.content_type = "text/html; charset=UTF-8" if response.content_type.nil?
  end
end

server = WEBrick::HTTPServer.new(:Port => 1234)
server.mount "/", MasterServlet
trap("INT") { server.shutdown }
server.start
