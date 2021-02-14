require "json"

class User

    def initialize
        @id = 0
        @name = ""
    end

    def initialize(id : UInt32, name : String)
        @id = id
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