module GMoney
  # = PortfolioFeedParser
  #
  # Parses Portfolio feeds returned from the Google Finance API
  #
  class PortfolioFeedParser < FeedParser
    def self.parse_portfolio_feed(portfolio_feed)
      parse_feed(portfolio_feed, Portfolio)
    end
  end 
end
