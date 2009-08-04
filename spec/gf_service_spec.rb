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
	  response.body.should be_eql('body')
	end
	
	it "should be able to make a post request" do
		@gfrequest.body = 'body'
		@gfrequest.method = :post
		
		response = request_helper(Net::HTTP::Post)
		
	  response.status_code.should be_eql(200)
	  response.body.should be_eql('body')
	end	
	
	it "should be able to make a put request" do
		@gfrequest.body = 'body'
		@gfrequest.method = :put

		response = request_helper(Net::HTTP::Put)

	 response.status_code.should be_eql(200)
	 response.body.should be_eql('body')
	end

	it "should be able to make a delete request" do
		@gfrequest.body = 'body'
		@gfrequest.method = :delete

		response = request_helper(Net::HTTP::Delete)

		response.status_code.should be_eql(200)
		response.body.should be_eql('body')
	end

	it "should raise an argument error when an invalid method type is used" do
		@gfrequest.body = 'body'
		@gfrequest.method = :invalid

		lambda {
		  response = request_helper(Net::HTTP::Get)
		}.should raise_error(ArgumentError)
	end
	
	def request_helper(class_type)
		#probably should just use a stub
		#http://martinfowler.com/articles/mocksArentStubs.html
		#http://rspec.info/documentation/mocks/
		url = mock
 		url.should_receive(:host).any_number_of_times.and_return(@gfrequest.url)
 		url.should_receive(:port).any_number_of_times.any_number_of_times.and_return(443)		
 		url.should_receive(:request_uri).any_number_of_times.any_number_of_times.and_return(@gfrequest.url)
 		url.should_receive(:scheme).any_number_of_times.any_number_of_times.and_return('https') 		
	  URI.should_receive(:parse).with(@gfrequest.url).any_number_of_times.and_return(url)	  

	  http = mock
		http.should_receive(:use_ssl=).with(true).any_number_of_times
		http.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE).any_number_of_times
	  Net::HTTP.should_receive(:new).with(@gfrequest.url, 443).any_number_of_times.and_return(http)
	  
		method_type = mock
	  method_type.should_receive(:body=).with(@gfrequest.body).any_number_of_times
	  class_type.should_receive(:new).with(@gfrequest.url).any_number_of_times.and_return(method_type)
	  
		res = mock
		res.should_receive(:body).any_number_of_times.and_return('body') #TODO - Doesn't always return a body, read google docs
		res.should_receive(:each).any_number_of_times
		res.should_receive(:code).any_number_of_times.and_return('200')	#TODO - Not always 200	

	  http.should_receive(:request).with(method_type).any_number_of_times.and_return(res)	
	  response = GMoney::GFService.send_request(@gfrequest)
	end	
end
