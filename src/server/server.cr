require "http/server"
require "../utils/api_utils"
require "uri"
require "json"

include Utils::ApiUtils

class BasicServer
  def initialize(port : Int32, host : String = "127.0.0.1")
    @routes = {} of String => Hash(String, (-> String))
    @routes["GET"] = Hash(String, (-> String)).new
    @routes["POST"] = Hash(String, (-> String)).new
    @port = port
    puts host
    @current_uri = URI.parse "http://#{host}:#{@port}"
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
    server.bind_tcp @current_uri.host.to_s, @port
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
