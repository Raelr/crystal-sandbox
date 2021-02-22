require "json"

module Utils::ApiUtils
  def wrap_response(code : Int32, data : JSON::Any::Type | Nil, message : String | Nil) : Hash
    {
      "status"  => code < 300 ? "Success" : "error",
      "code"    => code,
      "data"    => data,
      "message" => message,
    }
  end
end
