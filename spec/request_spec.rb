require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::GFRequest do

  before(:each) do
    @gfrequest = GMoney::GFRequest.new('http://someurl.com')
  end
  
  it "should accept body and method arguments" do
    gfrequest_with_body_and_method = GMoney::GFRequest.new('http://someurl.com', {:body => 'body text', :method => :post})
    gfrequest_with_body_and_method.body.should be_eql('body text')
    gfrequest_with_body_and_method.method.should be_eql(:post)
  end

  it "should use :get as the default method" do
    @gfrequest.method.should be_eql(:get)
  end  
  
  it "should be able to take header parameters as a Hash" do
    gfrequest_with_header_hash = GMoney::GFRequest.new('http://someurl.com', {:headers => {:header1 => 'some header'}})
    gfrequest_with_header_hash.headers.should == {:header1 => 'some header', "GData-Version" => 2, "Authorization" => "GoogleLogin auth="}
  end  
  
  it "should not accept random options" do
    lambda { 
      GMoney::GFRequest.new('http://someurl.com', {:random_opt => 'randomness'})
    }.should raise_error(NoMethodError)
  end  
end
