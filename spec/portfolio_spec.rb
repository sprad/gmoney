require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::Portfolio do
	before(:all) do
		@feed = File.read('spec/fixtures/default_portfolios_feed.xml')
	end
	
	before(:each) do
		@gf_request = GMoney::GFRequest.new('http://someurl')
		@gf_request.method = :get		
		
		@gf_response = GMoney::GFResponse.new
		@gf_response.status_code = 200
		@gf_response.body = @feed
	end	

  it "should return all Portfolios when status_code is 200" do   
		GMoney::Session.should_receive(:auth_token).and_return('toke')

	  GMoney::GFRequest.should_receive(:new).with('https://finance.google.com/finance/feeds/default/portfolios', 
	  	:headers => {"Authorization" => "GoogleLogin auth=toke"}).and_return(@gf_request)

	  GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)

		#

	  response = GMoney::Portfolio.all


	  response.status_code.should be_eql(200)
		response.body.should be_eql(@feed)
		
		#should parse the xml and convert it into a list of Portfolio objects
		#parse help: read the gf:data schema... should help a lot
	  

  end

  it "should return a portfolio with returns data is :with_returns == true" do
  end
  
  it "should return nil if the status code is not 200" do
  end
  
  it "should return an empty array if there are no portfolios" do #test with SSE google account (or does it default to 'My Portfolio')
  end    
end
