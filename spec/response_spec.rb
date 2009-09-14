require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::GFResponse do

  before(:each) do
    @gfresponse = GMoney::GFResponse.new
  end
  
  it "should accept body, status code, and header parameters" do
    @gfresponse.body = 'body'
    @gfresponse.status_code = 200
    @gfresponse.headers = {:header1 => 'header1', :header2 => 'header2'}
    
    @gfresponse.body.should be_eql('body')
    @gfresponse.status_code.should be_eql(200)
    @gfresponse.headers.should == {:header1 => 'header1', :header2 => 'header2'}
  end
end
