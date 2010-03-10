require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::GFSession do

  before(:each) do
    @auth_request = mock('GMoney::AuthenticationRequest')
  end

  it "should be able to retrieve an auth_token for a user" do   
    @auth_request.should_receive(:auth_token).with({}).and_return('toke')
    
    GMoney::AuthenticationRequest.should_receive(:new).with('email', 'password').once.and_return(@auth_request)
    GMoney::GFSession.login('email', 'password')
    GMoney::GFSession.auth_token.should be_eql('toke')
  end  
  
  it "should be able to retrieve an auth_token for a user with secure ssl" do
    @auth_request.should_receive(:auth_token).with({:secure => true}).and_return('secure toke')
    
    GMoney::AuthenticationRequest.should_receive(:new).with('email', 'password').once.and_return(@auth_request)
    GMoney::GFSession.login('email', 'password', :secure => true)
    GMoney::GFSession.auth_token.should be_eql('secure toke')
  end
  
  it "should retain the email address for this session" do
    @auth_request.should_receive(:auth_token).with({}).and_return('toke')

    GMoney::AuthenticationRequest.should_receive(:new).with('email@example.com', 'password').once.and_return(@auth_request)
    GMoney::GFSession.login('email@example.com', 'password')
    GMoney::GFSession.email.should be_eql('email@example.com')
  end
  
  it "should allow users to logout" do
    @auth_request.should_receive(:auth_token).with({}).and_return('toke')

    GMoney::AuthenticationRequest.should_receive(:new).with('email@example.com', 'password').once.and_return(@auth_request)
    GMoney::GFSession.login('email@example.com', 'password')
    
    GMoney::GFSession.email.should be_eql('email@example.com')
    GMoney::GFSession.auth_token.should be_eql('toke')

    GMoney::GFSession.logout
    
    GMoney::GFSession.email.should be_nil
    GMoney::GFSession.auth_token.should be_nil
  end  
  
  after(:all) do
    GMoney::GFSession.logout
  end
end
