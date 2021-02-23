# This module is a simple helper module for our API. So far its primary purpose is to handle JSON formatting, however
# it may do more at some point in the future.

require "json"

module Utils::ApiUtils
  # Wraps a response in JSON using a basic hash conversion. All nested JSON objects are converted to strings
  # with this method
  def wrap_response(code : Int32, message : String | Nil) : String
    {
      "status"  => code < 300 ? "Success" : "Error",
      "code"    => code,
      "data"    => nil,
      "message" => message,
    }.to_json
  end

  # Wraps a response in JSON using the JSON builder. This method is more rigorous in that it actually breaks
  # down JSON objects properly.
  def wrap_response(code : Int32, data : Array(Tuple), message : String | Nil) : String
    JSON.build do |json|
      json.object do
        json.field "status", code < 300 ? "Success" : "Error"
        json.field "code", code
        json.field "data" do
          # Honestly unsure at this point how we can handle objects nested further than this, but we can cross
          # that bridge when we get to it.
          # TODO: Work out how multiple levels of nesting would work.
          json.object do
            data.each do |tuple|
              json.field tuple[0], tuple[1]
            end
          end
        end
        json.field "message", message
      end
    end
  end
end
