module GMoney
	class Transaction
		class TransactionRequestError < StandardError; end
		
		attr_reader :id, :updated, :title

		attr_accessor :type, :date, :shares, :notes, :commission, :price
		
    def self.find_by_url(url)
      transactions = []
      
      response = GFService.send_request(GFRequest.new(url, :headers => {"Authorization" => "GoogleLogin auth=#{GFSession.auth_token}"}))
      
      if response.status_code == HTTPOK
      	TransactionFeedParser.parse_transaction_feed(response.body)
      else
      	raise TransactionRequestError
      end
    end			
	end
end
