require "http/server"
require "uri"

class BasicServer 
  def initialize
    @routes = {} of String => ( -> String)
  end

  def run 
    server : HTTP::Server = HTTP::Server.new do |context|
      if @routes.has_key?(context.request.path.to_s)
        context.response.respond_with_status(200, @routes[context.request.path.to_s].call)
      else
        context.response.respond_with_status(404, "404, Page not found")
      end
    end
    address = "http://#{server.bind_tcp 8080, false}/app"
    server.listen
  end

  def get(route, &block : (-> String)) 
    @routes[route] = block
  end
end

server = BasicServer.new

server.get "/" do 
  "Homepage!"
end

server.get "/app" do 
  "The app page!"
end

server.run




