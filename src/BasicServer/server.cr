require "http/server"
require "../User/user"
require "uri"
require "json"

class BasicServer 
  def initialize
    @routes = {} of String => ( -> String)
    @port = 8080
    @current_uri = URI.parse "http://localhost:#{@port}"
  end

  def run 
    server : HTTP::Server = HTTP::Server.new do |context|
      if @routes.has_key?(context.request.path.to_s)
        context.response.print(@routes[context.request.path.to_s].call)
      else
        context.response.print({"status" => 404, "message" => "Page not found"}.to_json)
      end
      @current_uri = URI.parse "#{@current_uri.scheme}://#{@current_uri.host}:#{@port}#{context.request.path.to_s}?#{context.request.query.to_s}"
    end
    server.bind_tcp 8080
    server.listen
  end

  def get(route, &block : (-> String)) 
    @routes[route] = block
  end

  def current_uri
    @current_uri
  end
end

server = BasicServer.new

server.get "/" do 
  "Homepage!"
end

server.get "/app" do 
  "The app page!"
end

server.get "/app/users" do 
  args = server.current_uri.query_params
  user = User.new(args["id"].to_u32, args["name"])
  {"status" => 200, "message" => user.serialize}.to_json.delete('\\')
end

server.run