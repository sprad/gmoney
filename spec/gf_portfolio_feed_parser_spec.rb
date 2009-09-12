require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::GFPorfolioFeedParser do
	before(:all) do
		feed = File.read('spec/fixtures/default_portfolios_feed.xml')
  	@portfolios = GMoney::GFPorfolioFeedParser.parse_portfolio_feed(feed)
  	
		empty_feed = File.read('spec/fixtures/empty_portfolio_feed.xml')
  	@default_portfolios = GMoney::GFPorfolioFeedParser.parse_portfolio_feed(empty_feed)
  	
		feed_with_returns = File.read('spec/fixtures/portfolio_feed_with_returns.xml')
  	@portfolios_with_returns = GMoney::GFPorfolioFeedParser.parse_portfolio_feed(feed_with_returns)
	end

  it "should create Portfolio objects out of portfolio feeds" do   
  	@portfolios.each do |portfolio|
  		portfolio.should be_instance_of(GMoney::Portfolio)
  	end
  end
  
	it "should return an Array of Portfolio objects equal to the size of Portfolio entries" do 		
		@portfolios.size.should be_eql(3)
	end
	
  it "should have portfolios with an id that starts with the Google Finance API URL" do
		@portfolios.each do |portfolio|
  		(portfolio.id.include? GMoney::GF_URL[8..-1]).should be_true
		end
  end	
	
  it "should return a default portfolio if the user has not made any of her own" do
  	@default_portfolios.size.should be_eql(1)
  	@default_portfolios[0].name.should be_eql('My Portfolio')
  	@default_portfolios.size.should be_eql(1)
  end
  
	it "should create Portfolio objects with valid numeric data types for the returns" do
		@portfolios_with_returns.each do |portfolio|
			portfolio.public_methods(false).each do |pm|
				if !(['id', 'feed_link', 'updated', 'name', 'currency_code', 'transactions'].include? pm) && !(pm.include?('='))
					return_val = portfolio.send(pm)
					return_val.should be_instance_of(Float) if return_val
				end
			end
		end
	end
end
