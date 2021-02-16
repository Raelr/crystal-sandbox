require "json"

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

    def serialize 
        string = JSON.build do |json|
            json.object do 
                json.field "id", @id
                json.field "name", @name
            end
        end
        return string
    end

end