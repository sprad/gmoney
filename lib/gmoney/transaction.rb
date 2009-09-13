module GMoney
	class Transaction
		attr_reader :id, :updated, :title

		attr_accessor :type, :date, :shares, :notes, :commission, :price
		
    def self.find_by_url(url)
      transactions = []
      
      response = GFService.send_request(GFRequest.new(url, :headers => {"Authorization" => "GoogleLogin auth=#{Session.auth_token}"}))
			GFTransactionFeedParser.parse_transaction_feed(response.body) if response.status_code == 200
    end			
	end
end
