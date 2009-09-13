require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::Portfolio do
	before(:all) do
		@feed = File.read('spec/fixtures/default_portfolios_feed.xml')
		@feed_with_returns = File.read('spec/fixtures/portfolio_feed_with_returns.xml')
	end
	
	before(:each) do
		@gf_request = GMoney::GFRequest.new('http://someurl')
		@gf_request.method = :get		
		
		@gf_response = GMoney::GFResponse.new
		@gf_response.status_code = 200
		@gf_response.body = @feed
		@positions = []
	end	

  it "should return all Portfolios when status_code is 200" do   
		GMoney::Session.should_receive(:auth_token).and_return('toke')

	  GMoney::GFRequest.should_receive(:new).with('https://finance.google.com/finance/feeds/default/portfolios', 
	  	:headers => {"Authorization" => "GoogleLogin auth=toke"}).and_return(@gf_request)

	  response = GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)
		
	  GMoney::Position.should_receive(:find_by_url).with('http://finance.google.com/finance/feeds/user@example.com/portfolios/14/positions', 
	  	{:with_returns => options[:with_returns]}).and_return(@positions)		
	  GMoney::Position.should_receive(:find_by_url).with('http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions', 
	  	{:with_returns => options[:with_returns]}).and_return(@positions)		
	  GMoney::Position.should_receive(:find_by_url).with('http://finance.google.com/finance/feeds/user@example.com/portfolios/8/positions', 
	  	{:with_returns => options[:with_returns]}).and_return(@positions)	  		  	
		
		portfolios = GMoney::Portfolio.all
		
		portfolios.size.should be_eql(3)
  end

  it "should return a portfolio with returns data is :with_returns == true" do
  end
  
  it "should return nil if the status code is not 200" do
  end
  
  it "should return an empty array if there are no portfolios" do #test with SSE google account (or does it default to 'My Portfolio')
  end
  
  it "should dynamically call methods for the portfolio attributes" do
  	#portfolio = GMoney::Portfolio.new("test", 'USD')
  	#portfolio.returnYTD = '0.233'
  	#puts portfoio.return_ytd
  end  
end
