module GMoney
	class Position
		attr_accessor :transactions

		attr_reader :id, :updated, :title, :feed_link, :exchange, :symbol, :shares, 
								:full_name, :gain_percentage, :return1w, :return4w, :return3m, 
		            :return_ytd, :return1y, :return3y, :return5y, :return_overall, 
		            :cost_basis, :days_gain, :gain, :market_value
    
		def initialize
			@transactions = []
		end
		
    def self.find_by_url(url, options = {})
      positions = []
      url += "?returns=true" if options[:with_returns]
      
      response = GFService.send_request(GFRequest.new(url, :headers => {"Authorization" => "GoogleLogin auth=#{Session.auth_token}"}))
      positions = GFPositionFeedParser.parse_position_feed(response.body) if response.status_code == 200

			positions.each do |position|
				position.transactions = Transaction.find_by_url(position.feed_link)
			end      
      positions
    end	
	end
end
