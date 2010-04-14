module GMoney
  # = GFResponse
  #
  # Wraps Responses that are received from Google
  #
  class GFResponse
    attr_accessor :status_code, :body, :headers
  end 
end
