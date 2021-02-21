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
      # Set headers to allow CORS access from origin and set response type to JSON
      context.response.content_type = "application/json"
      context.response.headers.add "Access-Control-Allow-Origin", "*"
      if @routes.has_key?(context.request.path.to_s)
        context.response.print(@routes[context.request.path.to_s].call)
      else
        context.response.print({"status" => 404, "message" => "Page not found"}.to_json)
      end
    end
    server.bind_tcp 8080
    server.listen
  end

  def get(route : String, &block : (-> String))
    @routes[route] = block
  end

  def current_uri
    @current_uri
  end

  def has_queries(queries : Array(String), uri_queries : URI::Params) : Bool
    contains_all_queries = true
    i = 0
    while i < queries.size
      unless uri_queries.has_key? queries[i]
        contains_all_queries = false
        break
      end
      i += 1
    end
    contains_all_queries
  end
end

server = BasicServer.new

server.get "/" do
  {"status" => 200, "message" => "Homepage"}.to_json
end

server.get "/app" do
  {"status" => 200, "message" => "The App Page!"}.to_json
end

server.get "/app/users/authentication" do
  args = server.current_uri.query_params
  if server.has_queries(["username", "password"], args)
    {"status" => 200, "message" => "Authentication request received to authenticate user: #{args["username"]} with password #{args["password"]}"}.to_json
  else
    {"status" => 400, "message" => "Error, bad request. The request is either missing a query or has invalid parameters."}.to_json
  end
end

# Endpoint for Receiving Users. Currently testing...
server.get "/app/users" do
  {"status" => 200, "message" => "Request recieved for the users endpoint!"}.to_json
end

server.run
