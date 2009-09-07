require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::GFXmlParser do
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

  it "should create Portfolio objects out of portfolio feeds" do   
  end
  
	it "should create Portfolio objects with valid data types" do #look to see how rails validates its Active Record objects
	end
	
	it "should return an Array of Portfolio objects equal to the size of Portfolio entries" do
	end
	
  it "should return an empty array if there are no portfolios" do #or is there always a default "My Portfolio"
  end
end

=begin
  
  it "should create Position objects out of position feeds" do   
  end  

  it "should create Transaction objects out of transaction feeds" do   
  end  
  
  it "should return an empty array if there are no portfolios" do #or is there always a default "My Portfolio"
  end    
=end
