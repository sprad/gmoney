require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::DataRequest do

  it "should be able to build the query string from parameters" do
    parameters = {'ids' => '12345', 'metrics' => 'country'}
    data_request = GMoney::DataRequest.new("", parameters)
    
    query_string = data_request.query_string   
    
    query_string.should match(/^\?/)
    
    query_string.sub!(/^\?/, '')

    query_string.split('&').sort.should eql(["ids=12345", "metrics=country"])    
  end	
  
  it "should return an empty query string if parameters are empty" do
    data_request = GMoney::DataRequest.new("")
    data_request.query_string.should be_empty
  end  
  
  it "should be able to build a uri" do
    url = 'http://example.com'
    expected = URI.parse('http://example.com')    
    GMoney::DataRequest.new(url).uri.should eql(expected)
  end
  
		
	it "should be able to make a request to the GAAPI" do
	  response = mock
	  response.should_receive(:is_a?).with(Net::HTTPOK).and_return(true)
	  
	  http = mock
		http.should_receive(:use_ssl=).with(true)
		http.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
		http.should_receive(:get).with('/data?key=value', 'Authorization' => 'GoogleLogin auth=toke').and_return(response)
	  
	  Net::HTTP.should_receive(:new).with('example.com', 443).and_return(http)
	  
 	  GMoney::Session.should_receive(:auth_token).with().and_return('toke')
	  
	  data_request = GMoney::DataRequest.new('https://example.com/data', 'key' => 'value')
	  data_request.send_request.should eql(response)
	end
end
