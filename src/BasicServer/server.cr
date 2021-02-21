require "http/server"
require "../User/user"
require "uri"
require "json"

class BasicServer
  def initialize
    @routes = {} of String => (-> String)
    @port = 8080
    @current_uri = URI.parse "http://localhost:#{@port}"
  end

  def run
    server : HTTP::Server = HTTP::Server.new do |context|
      @current_uri = URI.parse "#{@current_uri.scheme}://#{@current_uri.host}:#{@port}#{context.request.path.to_s}?#{context.request.query.to_s}"
      if @routes.has_key?(context.request.path.to_s)
        context.response.content_type = "application/json"
        context.response.print(@routes[context.request.path.to_s].call)
      else
        context.response.print({"status" => 404, "message" => "Page not found"}.to_json)
      end
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
  {"status" => 200, "message" => "Homepage"}.to_json
end

server.get "/app" do
  {"status" => 200, "message" => "The App Page!"}.to_json
end

server.get "/app/users" do
  args = server.current_uri.query_params
  # TODO: find a better way to represent this expression.
  has_id = args.has_key? "id"
  has_name = args.has_key? "name"
  response = ""
  if has_id && has_name
    user = User.new(args["id"].to_u32, args["name"])
    # TODO: Find a better way to serialise nested JSON objects
    response = JSON.build do |json|
      json.object do
        json.field "status", 200
        json.field "message" do
          json.object do
            json.field "id", user.id
            json.field "name", user.name
          end
        end
      end
    end
  else
    response = {"status" => 404, "message" => "Error, User not found"}.to_json
  end
  response
end

server.run
