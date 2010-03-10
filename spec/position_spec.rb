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
    @url = 'https://finance.google.com/finance/feeds/default/portfolios/9/positions' 
  
    @gf_request = GMoney::GFRequest.new(@portfolio_id)
    @gf_request.method = :get   
    
    @gf_response = GMoney::GFResponse.new
    @gf_response.status_code = 200
    @gf_response.body = @defaul_feed
    @transactions = []
  end 
  
  it "should have return a human readable (i.e. non-url) position id" do    
    @gf_response.body = @feed_with_returns
    
    positions = position_helper(@portfolio_id, {:returns => true})
    
    positions[0].pid.should be_eql("9/NASDAQ:JAVA")
    positions[1].pid.should be_eql("9/NASDAQ:GOOG")
    positions[2].pid.should be_eql("9/NASDAQ:AAPL")
  end

  it "should return all Positions when status_code is 200" do   
    @gf_response.body = @default_feed
    positions = position_helper(@portfolio_id)
    
    positions.size.should be_eql(5)
  end

  it "should return a position with returns data is :returns == true" do
    @gf_response.body = @feed_with_returns

    positions = position_helper(@portfolio_id, {:returns => true})
    
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
  
  
  it "should delete positions (with a single transaction) using a class method and id" do
    @trans = GMoney::Transaction.new
    @trans.instance_variable_set("@id", "#{@url}/NASDAQ:GOOG/transactions/21")
    
    position_delete_helper('9/NASDAQ:GOOG')
        
    GMoney::Position.delete('9/NASDAQ:GOOG').should be_nil
  end
  
  it "should delete positions (with multiple transactions) using a class method and id" do
    tran1 = GMoney::Transaction.new
    tran1.instance_variable_set("@id", "#{@url}/NASDAQ:GOOG/transactions/21")    
    tran2 = GMoney::Transaction.new
    tran2.instance_variable_set("@id", "#{@url}/NASDAQ:GOOG/transactions/22")    
    @trans = [tran1, tran2]
    
    position_delete_helper('9/NASDAQ:GOOG')
    
    GMoney::Position.delete('9/NASDAQ:GOOG').should be_nil
  end
  
  it "should delete positions when calling delete on an instance of a position" do
    position = GMoney::Position.new
    position.instance_variable_set("@id", "#{@url}/NASDAQ:GOOG")
     
    @trans = GMoney::Transaction.new
    @trans.instance_variable_set("@id", "#{@url}/NASDAQ:GOOG/transactions/21")

    position_delete_helper('9/NASDAQ:GOOG')

    position_return = position.delete
    position_return.should be_eql(position)
    position_return.frozen?.should be_true
  end  

  it "should raise a PositionDeleteError when there is an attempt to delete a position with a bad position id')" do
    lambda { GMoney::Position.delete("9/NASDAQ:GOOG/asdf") }.should raise_error(GMoney::Position::PositionDeleteError, 'Invalid Position ID')
  end  
  
  it "should raise a PositionDeleteError when there is an attempt to delete a position with a bad position id')" do
    GMoney::Transaction.should_receive(:find).with('9/NYSE:C').and_raise(GMoney::Transaction::TransactionRequestError.new('No position exists with ticker NYSE:C'))
    lambda { GMoney::Position.delete("9/NYSE:C") }.should raise_error(GMoney::Position::PositionDeleteError, 'No position exists with ticker NYSE:C')
  end    
  
  def position_helper(id, options = {})
    url = "#{GMoney::GF_PORTFOLIO_FEED_URL}/#{id.portfolio_id}/positions/#{id.position_id}"
    send_url = options[:returns] ? (url + '?returns=true') : url

    GMoney::GFRequest.should_receive(:new).with(send_url).and_return(@gf_request)

    GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)
    
    if options[:eager]
      feed_ids = get_feed_ids(@gf_response.body)   
      feed_ids.each do |feed_id|
        GMoney::Transaction.should_receive(:find).with(feed_id.position_feed_id, options).any_number_of_times.and_return(@transactions)        
      end
    end    
      
    GMoney::Position.find(id, options)
  end
  
  def position_delete_helper(id)
    GMoney::Transaction.should_receive(:find).with(id).and_return(@trans)    
    
    if @trans.class == GMoney::Transaction
      @trans.should_receive(:delete)
    else
      @trans.each {|t| t.should_receive(:delete)}      
    end 
  end      
end
