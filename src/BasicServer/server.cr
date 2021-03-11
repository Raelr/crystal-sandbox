require "http/server"
require "../User/user"
require "../utils/api_utils"
require "crypto/bcrypt/password"
require "uri"
require "json"
require "db"
require "pg"
require "yaml"

include Utils::ApiUtils

class BasicServer
  def initialize
    @routes = {} of String => Hash(String, (-> String))
    @routes["GET"] = Hash(String, (-> String)).new
    @routes["POST"] = Hash(String, (-> String)).new
    @port = 8080
    @current_uri = URI.parse "http://localhost:#{@port}"
    @current_body = JSON::Any
  end

  def run
    server : HTTP::Server = HTTP::Server.new do |context|
      @current_uri = URI.parse "#{@current_uri.scheme}://#{@current_uri.host}:#{@port}#{context.request.path.to_s}?#{context.request.query.to_s}"

      # Set headers to allow CORS access from origin and set response type to JSON
      context.response.content_type = "application/json"
      context.response.headers.add "Access-Control-Allow-Origin", "*"
      context.response.headers.add "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Content-Length"

      method = context.request.method

      if context.request.body.class != Nil
        @current_body = JSON.parse context.request.body.as IO
      end

      # Make sure that any OPTIONS request is handled
      if method == "OPTIONS"
        context.response.print(wrap_response(200, ""))
      else
        if @routes[method].has_key?(context.request.path.to_s)
          context.response.print(@routes[method][context.request.path.to_s].call)
        else
          context.response.print(wrap_response(404, "Page not found"))
        end
      end
    end
    server.bind_tcp 8080
    server.listen
  end

  # Aliases for defining different REST method routes.
  def get(route : String, &block : (-> String))
    @routes["GET"][route] = block
  end

  def post(route : String, &block : (-> String))
    @routes["POST"][route] = block
  end

  def current_uri
    @current_uri
  end

  def current_body
    @current_body
  end

  def has_queries(queries : Array(String), args : URI::Params) : Bool
    contains_all_queries = true
    queries.each do |query|
      unless args.has_key? query
        contains_all_queries = false
        break
      end
    end
    contains_all_queries
  end

  def has_body_param(param : String) : Bool
    @current_body.as(JSON::Any)[param]?.to_s != ""
  end

  def get_body_param(param : String) : JSON::Any | Nil
    if has_body_param(param)
      @current_body.as(JSON::Any)[param]
    else
      nil
    end
  end
end

# Load in the config file info (so we can avoid explicitly naming our DB URL)
# TODO: Create a separate object for our config info
db_uri = ""
config = File.open("configuration.yaml") do |file|
  yaml = YAML.parse file
  db_uri = yaml["db"]["pg"]["uri"]
end

puts db_uri

server = BasicServer.new

server.get "/" do
  wrap_response(200, "Homepage")
end

server.get "/app" do
  wrap_response(200, "The App Page!")
end

server.post "/app/users/register" do
  status = {400, "Invalid Parameters. Please ensure all data is passed in the object's body"}
  if server.has_body_param("username") && server.has_body_param("password")
    username = server.get_body_param "username".to_s
    password = server.get_body_param "password".to_s
    user_exists = false
    DB.open db_uri.to_s do |db|
      db.query "SELECT username, password FROM users WHERE username='#{username}'" do |rs|
        rs.each do
          status = {400, "User already exists!"}
          user_exists = true
        end
      end
      unless user_exists
        db.exec("insert into users values ($1, $2)", username, Crypto::Bcrypt::Password.create(password.to_s, cost: 14))
        status = {200, "User successfully added!"}
      end
    end
  end
  wrap_response(status[0], status[1])
end

server.post "/app/users/authentication" do
  if server.has_body_param("username") && server.has_body_param("password")
    username = server.get_body_param "username".to_s
    password = server.get_body_param "password".to_s
    status = {401, "Username or Password are incorrect!"}
    DB.open db_uri.to_s do |db|
      db.query "SELECT password FROM users WHERE username='#{username}';" do |rs|
        rs.each do
          pwd = Crypto::Bcrypt::Password.new rs.read(String)
          if pwd.verify(password.to_s)
            status = {200, "User Authenticated!"}
          end
        end
      end
    end
    wrap_response(status[0], [{"username", username}, {"password", password}], status[1])
  else
    wrap_response(400, "Error, bad request. The request is either missing a query or has invalid parameters.")
  end
end

# Endpoint for Receiving Users. Currently testing...
server.get "/app/users" do
  wrap_response(200, "Request recieved for the users endpoint!")
end

server.run
