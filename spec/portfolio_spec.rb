require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::Portfolio do
	before(:all) do
		@feed = File.read('spec/fixtures/default_portfolios_feed.xml')
	end

  it "should return all Portfolios" do   
		gf_request = mock("GMoney::GFRequest")
	  GMoney::GFRequest.should_receive(:new).with('https://finance.google.com/finance/feeds/default/portfolios').and_return(gf_request)
	  
	  #TODO Update this to handle the new paradigm with GFService
	  # session = GMoney::Session.login('user', 'pass')
	  # gfr = GMoney::GFRequest.new("url")
	  # gfr.headers["Content-Type"] = "xml/atom-whatever"
	  # gfr.headers["Authorization"] = "Google Login auth=#{session}"
	  # gfr.body = "some xml content # if you are posting data
	  # gfr.method = :get #by default, or :post, :put, :delete
		# response = GMoney::GFService.send_request(gfr) #response would therefore be equal to @feed
	  
		data_request.should_receive(:send_request).and_return(@feed)
		GMoney::Portfolio.all.should be_eql(@feed)
		#GMoney::Portfolio.all.should == {}
  end
end
