module GMoney
	class Portfolio	
		attr_accessor :title, :currency_code, :positions
		            	
		attr_reader :id, :feed_link, :updated, :gain_percentage, :return1w, :return4w, :return3m, 
		            :return_ytd, :return1y, :return3y, :return5y, :return_overall, 
		            :cost_basis, :days_gain, :gain, :market_value
		
		def initialize()		
			@positions = []
		end
		
    def self.all(options = {})
      url = "#{GF_FEED_URL}/portfolios"
      url += "?returns=true" if options[:with_returns]
      portfolios = []
      
      response = GFService.send_request(GFRequest.new(url, :headers => {"Authorization" => "GoogleLogin auth=#{Session.auth_token}"}))
      
      portfolios = GFPortfolioFeedParser.parse_portfolio_feed(response.body) if response.status_code == 200

			portfolios.each do |portfolio|
				portfolio.positions = Position.find_by_url(portfolio.feed_link, {:with_returns => options[:with_returns]})
			end      
      portfolios  
    end
	end
end
