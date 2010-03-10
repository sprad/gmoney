require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::GFService do  
  before(:all) do
    @feed = File.read('spec/fixtures/default_portfolios_feed.xml')
  end

  before(:each) do
    @gfrequest = GMoney::GFRequest.new('https://someurl.com')   
    @gfresponse = GMoney::GFResponse.new
    @gfresponse.status_code = 200
    @gfresponse.body = @feed
  end
  
  it "should be able to make a get request" do    
    @gfrequest.body = ''
    response = request_helper(Net::HTTP::Get)
    
    response.status_code.should be_eql(@gfresponse.status_code)
    response.body.should be_eql(@feed)
  end
  
  it "should be able to make a post request" do
    @gfrequest.body = 'body'
    @gfrequest.method = :post
    @gfresponse.status_code = 201
    
    response = request_helper(Net::HTTP::Post)
    
    response.status_code.should be_eql(@gfresponse.status_code)
    response.body.should be_eql(@feed)
  end 
  
  it "should be able to make a put request" do
    @gfrequest.body = 'body'
    @gfrequest.method = :put

    response = request_helper(Net::HTTP::Put)

    response.status_code.should be_eql(@gfresponse.status_code)
    response.body.should be_eql(@feed)
  end

  it "should be able to make a delete request" do
    @gfrequest.body = 'body'
    @gfrequest.method = :delete

    response = request_helper(Net::HTTP::Delete)

    response.status_code.should be_eql(@gfresponse.status_code)
  end

  it "should raise an argument error when an invalid method type is used" do
    @gfrequest.body = 'body'
    @gfrequest.method = :invalid

    lambda {
      response = error_request_helper(Net::HTTP::Get)
    }.should raise_error(ArgumentError)
  end

  it "should allow for request headers" do
    @gfrequest.body = ''
    @gfrequest.method = :get
    @gfrequest.headers = {:h1 => 'header 1', :h2 => 'header 2'}
    
    response = request_helper(Net::HTTP::Get, true)
    
    response.status_code.should be_eql(@gfresponse.status_code)
    response.body.should be_eql(@feed)        
  end
  
  def request_helper(class_type, with_headers = false)
    set_url_expectations    
    http = set_http_expectations
    request = set_request_expecations(class_type)
    set_header_expectations(request)
    res = set_response_expecations

    http.should_receive(:request).with(request).and_return(res) 
    GMoney::GFService.send_request(@gfrequest)
  end
  
  def error_request_helper(class_type)
    set_url_expectations    
    set_http_expectations 
    GMoney::GFService.send_request(@gfrequest)
  end  
  
  def set_url_expectations
    url = mock
    url.should_receive(:host).and_return(@gfrequest.url)
    url.should_receive(:port).and_return(443)   
    url.should_receive(:request_uri).any_number_of_times.and_return(@gfrequest.url)
    url.should_receive(:scheme).and_return('https')     
    URI.should_receive(:parse).with(@gfrequest.url).and_return(url)
    url
  end
  
  def set_http_expectations
    http = mock
    http.should_receive(:use_ssl=).with(true)
    http.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
    Net::HTTP.should_receive(:new).with(@gfrequest.url, 443).and_return(http)
    http
  end
  
  def set_request_expecations(class_type)
    method_type = mock
    method_type.should_receive(:body=).with(@gfrequest.body)
    class_type.should_receive(:new).with(@gfrequest.url).and_return(method_type)
    method_type
  end
  
  def set_response_expecations
    res = mock
    res.should_receive(:body).and_return(@feed)
    res.should_receive(:each).and_yield(:rh1,'rheader1').and_yield(:rh2,'rheader2')
    res.should_receive(:code).and_return(@gfresponse.status_code)
    res
  end
  
  def set_header_expectations(req)
    req.should_receive(:[]=).with(:h1, "header 1").any_number_of_times
    req.should_receive(:[]=).with(:h2, "header 2").any_number_of_times
    req.should_receive(:[]=).with("GData-Version", 2).any_number_of_times
    req.should_receive(:[]=).with("Authorization", "GoogleLogin auth=").any_number_of_times    
  end
end
