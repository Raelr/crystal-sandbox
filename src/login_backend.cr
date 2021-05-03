require "./utils/configuration"

Configuration.new("configuration.yaml")

Granite::Connections << Granite::Adapter::Pg.new(name: "pg", url: Configuration.instance.database_url)

require "./server/server"
require "db"
require "pg"
require "yaml"
require "crypto/bcrypt/password"
require "./user/user"

config = Configuration.instance

puts "POSTGRES SETUP | Configured database URL: \"#{config.database_url}\""

begin 
  Models::User.migrator.create
rescue ex
  puts ex.message
end

server = BasicServer.new(config.server_config.port, config.server_config.host)

server.get "/" do 
  wrap_response(200, "Hello!")
end

if Models::User.exists? "Aryeh"
  Models::User.find!("Aryeh").destroy!
end

u = Models::User.new
u.username = "Aryeh"
u.password = "blah"
u.save

# TODO: add model creation logic to api endpoints (below this)

server.post "/app/users/register" do
  puts config.database_url
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