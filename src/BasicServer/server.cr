require "http/server"
require "../User/user"
require "../utils/api_utils"
require "uri"
require "json"

include Utils::ApiUtils

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
        context.response.print(wrap_response(404, nil, "Page not found").to_json)
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
    queries.each do |query|
      unless uri_queries.has_key? query
        contains_all_queries = false
        break
      end
    end
    contains_all_queries
  end
end

server = BasicServer.new

server.get "/" do
  wrap_response(200, nil, "Homepage").to_json
end

server.get "/app" do
  wrap_response(200, nil, "The App Page!").to_json
end

server.get "/app/users/authentication" do
  args = server.current_uri.query_params
  if server.has_queries(["username", "password"], args)
    wrap_response(200, nil, "Authentication request received to authenticate user: #{args["username"]} with password #{args["password"]}").to_json
  else
    wrap_response(400, nil, "Error, bad request. The request is either missing a query or has invalid parameters.Th").to_json
  end
end

# Endpoint for Receiving Users. Currently testing...
server.get "/app/users" do
  wrap_response(200, nil, "Request recieved for the users endpoint!").to_json
end

server.run
