require "http/server"
require "uri"

class BasicServer 
  def initialize
    @routes = {} of String => ( -> String)
    @current_path = ""
  end

  def run 
    server : HTTP::Server = HTTP::Server.new do |context|
      address = "http://localhost:8080#{context.request.path.to_s}?#{context.request.query.to_s}"
      uri = URI.parse address
      puts uri.path
      puts uri.query
      puts address
      if @routes.has_key?(context.request.path.to_s)
        context.response.respond_with_status(200, @routes[context.request.path.to_s].call)
      else
        context.response.respond_with_status(404, "Page not found")
      end
      @current_path = context.request.path.to_s
    end
    server.bind_tcp 8080
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




