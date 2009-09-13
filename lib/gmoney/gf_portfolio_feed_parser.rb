module GMoney
	class GFPortfolioFeedParser < GFFeedParser
		def self.parse_portfolio_feed(portfolio_feed)
			parse_feed(portfolio_feed, Portfolio)
		end
	end	
end
