require "./server/server"
require "db"
require "pg"
require "yaml"
require "crypto/bcrypt/password"
require "./utils/configuration"

config = Utils::ApiUtils::Configuration.new("configuration.yaml")

puts "POSTGRES SETUP | Configured database URL: \"#{config.database_url}\""

server = BasicServer.new(8080, "0.0.0.0")

server.get "/" do 
  wrap_response(200, "Hello!")
end

server.post "/app/users/register" do
  status = {400, "Invalid Parameters. Please ensure all data is passed in the object's body"}
  if server.has_body_param("username") && server.has_body_param("password")
    username = server.get_body_param "username".to_s
    password = server.get_body_param "password".to_s
    user_exists = false
    DB.open config.database_url do |db|
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
    DB.open config.database_url do |db|
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

server.run