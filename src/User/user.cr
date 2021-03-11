require "json"

# TODO: Make this class relevant again.
class User
  include JSON::Serializable

  def initialize
    @id = 0
    @name = ""
  end

  def initialize(id : UInt32, name : String)
    @[JSON::Field(key: "id")]
    @id = id

    @[JSON::Field(key: "name")]
    @name = name
  end

  def id
    @id
  end

  def name
    @name
  end
end
