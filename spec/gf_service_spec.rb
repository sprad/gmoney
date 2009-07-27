require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::GFService do

	before(:each) do
		@gfrequest = GMoney::GFRequest.new('https://someurl.com')
		#set attrs

		@gfresponse = GMoney::GFResponse.new
		@gfresponse.status_code = 200
		@gfresponse.body = 'body' #fixture code?
	end
	
	it "should be able to make a get request" do
		@gfrequest.body = 'body' # does the request always need a body?
		
		response = request_helper(Net::HTTP::Get)
		
	  response.status_code.should be_eql(200)
	  response.body.should be_eql('body dawg')
	end
	
	it "should be able to make a post request" do
		@gfrequest.body = 'body'
		@gfrequest.method = :post
		
		response = request_helper(Net::HTTP::Post)
		
	  response.status_code.should be_eql(200)
	  response.body.should be_eql('body dawg')
	end	
	
	def request_helper(class_type)
		url = mock	
 		url.should_receive(:host).and_return(@gfrequest.url)
 		url.should_receive(:port).and_return(443)		
 		url.should_receive(:request_uri).and_return(@gfrequest.url)
 		url.should_receive(:scheme).and_return('https') 		
	  URI.should_receive(:parse).with(@gfrequest.url).and_return(url)	  

	  http = mock
		http.should_receive(:use_ssl=).with(true)
		http.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)	  
	  Net::HTTP.should_receive(:new).with(@gfrequest.url, 443).and_return(http)
	  
		method_type = mock
	  method_type.should_receive(:body=).with(@gfrequest.body)
	  class_type.should_receive(:new).with(@gfrequest.url).and_return(method_type)
	  
		res = mock
		res.should_receive(:body).and_return('body dawg')
		res.should_receive(:each)
		res.should_receive(:code).and_return('200')		

	  http.should_receive(:request).with(method_type).and_return(res)	
	  response = GMoney::GFService.send_request(@gfrequest)
	end	
end
