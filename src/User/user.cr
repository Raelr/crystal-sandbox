require "granite/adapter/pg"
require "../utils/configuration"

module Models
  
  class User < Granite::Base
    connection pg
    table users
    column username : String, primary: true, auto: false
    column password : String
  end
end
