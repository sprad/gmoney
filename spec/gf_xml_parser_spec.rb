require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::GFXmlParser do
	before(:all) do
		feed = File.read('spec/fixtures/default_portfolios_feed.xml')
  	@portfolios = GMoney::GFXmlParser.parse_portfolio(feed)
  	
		empty_feed = File.read('spec/fixtures/empty_portfolio_feed.xml')
  	@default_portfolios = GMoney::GFXmlParser.parse_portfolio(empty_feed)
  	
		feed_with_returns = File.read('spec/fixtures/portfolio_feed_with_returns.xml')
  	@portfolios_with_returns = GMoney::GFXmlParser.parse_portfolio(feed_with_returns)
	end

  it "should create Portfolio objects out of portfolio feeds" do   
  	@portfolios.each do |portfolio|
  		portfolio.should be_instance_of(GMoney::Portfolio)
  	end
  end
  
	it "should return an Array of Portfolio objects equal to the size of Portfolio entries" do 		
		@portfolios.size.should be_eql(3)
	end
	
  it "should do some extra stuff when with_returns portfolios are used" do
	  @portfolios_with_returns.each do |portfolio_with_returns|
	  	#portfolio_with_returns.
	  end
  end	
	
  it "should have portfolios with an id that starts with the Google Finance API URL" do
		@portfolios.each do |portfolio|
  		(portfolio.id.include? GMoney::GF_URL[8..-1]).should be_true
		end
  end	
	
  it "should return a default portfolio if the user has not made any of her own" do
  	@default_portfolios.size.should be_eql(1)
  	@default_portfolios[0].name.should be_eql('My Portfolio')
  end
  
	it "should create Portfolio objects with valid data types" do #look to see how rails validates its Active Record objects
	end 
	
=begin
  
  it "should create Position objects out of position feeds" do   
  end  

  it "should create Transaction objects out of transaction feeds" do   
  end  
  
  it "should return an empty array if there are no portfolios" do #or is there always a default "My Portfolio"
  end    
=end
end
