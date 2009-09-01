require 'net/http'
require 'net/https'
require 'uri'

module GMoney 
  class GFService 
    def self.send_request(request)       
      url = URI.parse(request.url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      case request.method
      when :get
        req = Net::HTTP::Get.new(url.request_uri)
      when :put
        req = Net::HTTP::Put.new(url.request_uri)
      when :post
        req = Net::HTTP::Post.new(url.request_uri)
      when :delete
        req = Net::HTTP::Delete.new(url.request_uri)
      else
        raise ArgumentError, "Unsupported HTTP method specified."
      end
      
      req.body = request.body.to_s
      
      request.headers.each do |key, value|
        req[key] = value
      end
           
      res = http.request(req)
      
      response = GFResponse.new
      response.body = res.body
      response.headers = Hash.new
      res.each do |key, value|
        response.headers[key] = value
      end
      
      response.status_code = res.code.to_i
      
      return response
    end
  end
end
