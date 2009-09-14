require File.join(File.dirname(__FILE__), '/spec_helper')

CA_CERT_FILE = File.join(File.dirname(__FILE__), '..', 'fixtures/cacert.pem')

describe GMoney::AuthenticationRequest do

  before(:each) do
    @request = GMoney::AuthenticationRequest.new('email', 'password')
    @response = mock
  end
  
  it "should have a collection of parameters that include the email and password" do
    expected = 
      {
        'Email'       => 'user@example.com',
        'Passwd'      => 'fuzzybunnies',
        'accountType' => 'HOSTED_OR_GOOGLE',
        'service'     => 'finance',
        'source'      => 'gmoney-001'      
      }
    
    request = GMoney::AuthenticationRequest.new('user@example.com', 'fuzzybunnies')
    request.parameters == expected
  end
  
  it "should have a URI" do
    @request.uri.should be_eql(URI.parse('https://www.google.com/accounts/ClientLogin'))
  end
  
  it "should be able to send a request to the GAAPI service with proper ssl" do        
    @request.should_receive(:build_request).and_return('post')    
    @response.should_receive(:is_a?).with(Net::HTTPOK).and_return(true)

    http = mock()
    http.should_receive(:use_ssl=).with(true)
    http.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)
    http.should_receive(:ca_file=).with(CA_CERT_FILE)
    http.should_receive(:request).with('post').and_yield(@response)
    
    Net::HTTP.should_receive(:new).with('www.google.com', 443).and_return(http)
    @request.send_request(OpenSSL::SSL::VERIFY_PEER)    
  end  
  
  it "should be able to send a request to the GAAPI service with ignoring ssl" do
    @request.should_receive(:build_request).and_return('post')    
    @response.should_receive(:is_a?).with(Net::HTTPOK).and_return(true)

    http = mock
    http.should_receive(:use_ssl=).with(true)
    http.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
    http.should_receive(:request).with('post').and_yield(@response)
    
    Net::HTTP.should_receive(:new).with('www.google.com', 443).and_return(http)
    @request.send_request(OpenSSL::SSL::VERIFY_NONE)
  end  

  it "should be able to build a request for the GAAPI service" do
    params = "param"
    @request.should_receive(:parameters).and_return(params)

    post = mock
    post.should_receive(:set_form_data).with(params)

    Net::HTTP::Post.should_receive(:new).with('/accounts/ClientLogin').and_return(post)
    @request.build_request
  end
  
  it "should be able to retrieve an auth_token from the body" do
    response_data =
      "SID=mysid\n" +
      "LSID=mylsid\n" +
      "Auth=auth_token\n"

    @request.should_receive(:send_request).with(OpenSSL::SSL::VERIFY_NONE).and_return(stub(:body => response_data))
    @request.auth_token.should be_eql('auth_token')
  end  
  
  it "should use VERIFY_PEER if auth_token needs to be secure" do
    response_data =
      "SID=mysid\n" +
      "LSID=mylsid\n" +
      "Auth=auth_token\n"
    
    @request.should_receive(:send_request).with(OpenSSL::SSL::VERIFY_PEER).and_return(stub(:body => response_data))
    @request.auth_token(:secure => true).should be_eql('auth_token')        
  end  
  
  it "should raise an exception when requesting an auth_token when the authorization fails" do
    @request.stub!(:build_request)
    @response.should_receive(:is_a?).with(Net::HTTPOK).and_return(false)

    http = stub
    http.stub!(:use_ssl=)
    http.stub!(:verify_mode=)
    http.stub!(:request).and_yield(@response)

    Net::HTTP.stub!(:new).with('www.google.com', 443).and_return(http)
    
    lambda { @request.send_request(OpenSSL::SSL::VERIFY_NONE) }.should raise_error(GMoney::AuthenticationRequest::AuthError)
  end  
end
