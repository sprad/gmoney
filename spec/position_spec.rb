require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::Position do
  before(:all) do
    @default_feed = File.read('spec/fixtures/positions_feed_for_portfolio_9.xml')
    @feed_with_returns = File.read('spec/fixtures/positions_feed_for_portfolio_9r.xml')
    @empty_feed = File.read('spec/fixtures/positions_feed_for_portfolio_14.xml')
    @feed_for_port9_goog = File.read('spec/fixtures/position_feed_for_9_GOOG.xml')
  end
  
  before(:each) do
    @portfolio_id = '9'
  
    @gf_request = GMoney::GFRequest.new(@portfolio_id)
    @gf_request.method = :get   
    
    @gf_response = GMoney::GFResponse.new
    @gf_response.status_code = 200
    @gf_response.body = @defaul_feed
    @transactions = []
  end 

  it "should return all Positions when status_code is 200" do   
    @gf_response.body = @default_feed
    positions = position_helper(@portfolio_id)
    
    positions.size.should be_eql(5)
  end

  it "should return a position with returns data is :with_returns == true" do
    @gf_response.body = @feed_with_returns

    positions = position_helper(@portfolio_id, {:with_returns => true})
    
    positions.size.should be_eql(5)
    positions[0].cost_basis.should be_eql(615.00)
    positions[0].gain_percentage.should be_eql(0.1182926829)
    positions[0].return4w.should be_eql(0.09390243902)

    positions[4].days_gain.should be_eql(28.500375)
  end
  
  it "should raise an error if the position request does not return an OK status code" do
    @gf_response.status_code = 404  
    lambda { position_helper(@portfolio_id) }.should raise_error(GMoney::Position::PositionRequestError)
  end

  it "should return a specific position if the user requests a specific position" do
    @portfolio_id = '9/NASDAG:GOOG'
    @gf_response.body = @feed_for_port9_goog
    
    position = position_helper(@portfolio_id)

    position.cost_basis.should be_eql(136300.25)
    position.return1w.should be_eql(0.002075448663)
  end
  
  
  it "should raise an error message when a user request an invalid Position" do
    @portfolio_id = '9/NASDAG:ASDF'
    @gf_response.status_code = 404
    @gf_response.body = "No position exists with ticker NASDAQ:ASDF"

    lambda { position_helper(@portfolio_id)}.should raise_error(GMoney::Position::PositionRequestError, @gf_response.body)
  end
  
  it "should grab the latest transactions when :refresh is used" do 
    @position_id = '9/NASDAG:GOOG'
    @transactions = [GMoney::Transaction.new, GMoney::Transaction.new, GMoney::Transaction.new]
    
    @gf_response.body = @feed_for_port9_goog
    position = position_helper(@position_id, :refresh => true)
          
    GMoney::Transaction.should_receive(:find).with(position.id.position_feed_id, {:refresh => true}).and_return(@transactions)
    
    position.transactions(:refresh => true).size.should be_eql(3)
  end
  
  it "should grab cached transactions when :refresh is not used" do 
    @position_id = '9/NASDAG:GOOG'
    @transactions = [GMoney::Transaction.new, GMoney::Transaction.new, GMoney::Transaction.new]
    
    @gf_response.body = @feed_for_port9_goog
    position = position_helper(@position_id, :eager => true)
          
    GMoney::Transaction.should_not_receive(:find).with(position.id.position_feed_id, {:eager => true})
    position.transactions(:eager => true).size.should be_eql(3)
  end
  
  def position_helper(id, options = {})
    GMoney::GFSession.should_receive(:auth_token).and_return('toke')

    url = "#{GMoney::GF_PORTFOLIO_FEED_URL}/#{id.portfolio_id}/positions/#{id.position_id}"
    send_url = options[:with_returns] ? (url + '?returns=true') : url

    GMoney::GFRequest.should_receive(:new).with(send_url, :headers => {"Authorization" => "GoogleLogin auth=toke"}).and_return(@gf_request)

    GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)
    
    if options[:eager]
      feed_ids = get_feed_ids(@gf_response.body)   
      feed_ids.each do |feed_id|
        GMoney::Transaction.should_receive(:find).with(feed_id.position_feed_id, options).any_number_of_times.and_return(@transactions)        
      end
    end    
      
    GMoney::Position.find(id, options)
  end
end
