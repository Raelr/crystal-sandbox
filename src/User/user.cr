require "granite/adapter/pg"

class User < Granite::Base

  connection pg
  column username : String, primary: true, auto: false
  column password : String

end
