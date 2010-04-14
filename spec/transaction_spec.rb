require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::Transaction do
  before(:all) do
    @goog_feed = File.read('spec/fixtures/transactions_feed_for_GOOG.xml')
    @goog_feed_1 = File.read('spec/fixtures/transaction_feed_for_GOOG_1.xml')
    @new_transaction_feed = File.read('spec/fixtures/new_transaction_feed.xml')
  end
  
  before(:each) do
    @url = "#{GMoney::GF_URL}/feeds/default/portfolios/9/positions/NASDAQ:GOOG/transactions"
    @transaction_id = '9/NASDAQ:GOOG'
    
    @gf_request = GMoney::GFRequest.new(@url)
    @gf_request.method = :get   
    
    @gf_response = GMoney::GFResponse.new
    @gf_response.status_code = 200
    @gf_response.body = @goog_feed
  end
  
  it "should have return a human readable (i.e. non-url) transaction id" do
    transactions = transaction_helper(@transaction_id)
    transactions[0].tid.should be_eql("9/NASDAQ:GOOG/2")
    transactions[1].tid.should be_eql("9/NASDAQ:GOOG/10")
  end  

  it "should return the portfolio id when it is set or infer the portfolio id from the transaction id when the portfolio id is not set" do
    transaction = GMoney::Transaction.new
    transaction.portfolio.should be_nil
    
    transaction.portfolio = '18'
    transaction.portfolio.should be_eql('18')
    
    transaction.instance_variable_set("@id", "http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions/NASDAQ:GOOG/transactions/12")
    transaction.portfolio.should be_eql('9')

    transaction = GMoney::Transaction.new
    transaction.instance_variable_set("@id", "http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions/NASDAQ:GOOG/transactions/12")
    transaction.portfolio.should be_eql('9')
  end

  it "should return the ticker id when it is set or infer the ticker id from the transaction id when the ticker id is not set" do
    transaction = GMoney::Transaction.new
    transaction.ticker.should be_nil
    
    transaction.ticker = 'NASDAQ:AAPL'
    transaction.ticker.should be_eql('NASDAQ:AAPL')
    
    transaction.instance_variable_set("@id", "http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions/NASDAQ:GOOG/transactions/12")
    transaction.ticker.should be_eql('NASDAQ:GOOG')

    transaction = GMoney::Transaction.new
    transaction.instance_variable_set("@id", "http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions/NASDAQ:GOOG/transactions/12")
    transaction.ticker.should be_eql('NASDAQ:GOOG')  
  end
  
  it "should not allow users to set a portfolio on a transaction for transactions that have already been saved" do
    transaction = GMoney::Transaction.new
    transaction.instance_variable_set("@id", "http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions/NASDAQ:GOOG/transactions/12")

    lambda { transaction.portfolio = 10 }.should raise_error(GMoney::Transaction::TransactionIdError, "You can't modify the portfolio for a Transaction that already has an id")  
  end
  
  it "should not allow users to set a portfolio on a transaction for transactions that have already been saved" do
    transaction = GMoney::Transaction.new
    transaction.instance_variable_set("@id", "http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions/NASDAQ:GOOG/transactions/12")
    lambda { transaction.ticker = "NASDAQ::AAPL" }.should raise_error(GMoney::Transaction::TransactionIdError, "You can't modify the ticker for a Transaction that already has an id")  
  end
  
  it "should return all Tranasactions when the status code is 200" do
    transactions = transaction_helper(@transaction_id)
  
    transactions.size.should be_eql(4)
    transactions[1].commission.should be_eql(12.75)
    transactions[1].notes.should be_eql('Buy some more Google.')
  end
  
  it "should raise an error when the status code is not 200" do
    @transaction_id += '/1'
    @gf_response.status_code = 404
    @gf_response.body = "No transaction exists with tid 1"
  
    lambda { transaction_helper(@transaction_id) }.should raise_error(GMoney::Transaction::TransactionRequestError, @gf_response.body)  
  end

  it "should return a specific transactions if the user request a specific transaction" do
    @transaction_id += '/2'
    @gf_response.body = @goog_feed_1
    transaction = transaction_helper(@transaction_id)
  
    transaction.commission.should be_eql(50.0)
    transaction.price.should be_eql(400.0)
  end  
  
  it "should delete transactions using a class method and id" do
    @gf_request = GMoney::GFRequest.new("#{@url}/24")
    @gf_request.method = :post
    
    @gf_response = GMoney::GFResponse.new
    @gf_response.status_code = 200
    
    transaction_delete_helper("#{@url}/24")
    
    GMoney::Transaction.delete('9/NASDAQ:GOOG/24').should be_nil
  end

  it "should delete transactions when calling delete on an instance of a transaction" do
    @gf_request = GMoney::GFRequest.new("#{@url}/21")
    @gf_request.method = :post
    
    @gf_response = GMoney::GFResponse.new
    @gf_response.status_code = 200
    
    transaction = GMoney::Transaction.new
    transaction.instance_variable_set("@id", "#{@url}/21")
     
    transaction_delete_helper("#{@url}/21")

    transaction_return = transaction.delete
    transaction_return.should be_eql(transaction)
    transaction_return.frozen?.should be_true
  end

  it "should raise a TransactionDeleteError when there is an attempt to delete a transaction from a portfolio that doesn't exist')" do
    @gf_request = GMoney::GFRequest.new("#{@url}/24")
    @gf_request.method = :post
    
    @gf_response = GMoney::GFResponse.new
    @gf_response.status_code = 400
    @gf_request.body = "Invalid Portfolio"

    transaction_delete_helper("#{@url}/24")

    lambda { GMoney::Transaction.delete("9/NASDAQ:GOOG/24") }.should raise_error(GMoney::Transaction::TransactionDeleteError, @gf_response.body)
  end
  
  it "should create only valid transactions" do
    trans = GMoney::Transaction.new
    
    #Make is_valid_transaction? method public for testing purposes
    def trans.public_is_valid_transaction?(*args)
      is_valid_transaction?(*args)
    end 
    
    trans.portfolio = 1
    trans.ticker = "NYSE:GLD"    
    trans.type = GMoney::BUY
    trans.public_is_valid_transaction?.should be_true
    
    trans.type = GMoney::SELL
    trans.public_is_valid_transaction?.should be_true    
    
    trans.type = 'Buy to Cover'
    trans.public_is_valid_transaction?.should be_true    

    trans.type = 'Sell Short'
    trans.public_is_valid_transaction?.should be_true        
    
    trans.portfolio = 1
    trans.ticker = "NYSE:GLD"    
    trans.type = nil
    trans.public_is_valid_transaction?.should be_false
    
    trans.portfolio = 1
    trans.ticker = "NYSE:GLD"    
    trans.type = 'buy'
    trans.public_is_valid_transaction?.should be_false
    
    trans.portfolio = 1
    trans.ticker = "   "
    trans.type = GMoney::BUY
    trans.public_is_valid_transaction?.should be_false
    
    trans.portfolio = "  "
    trans.ticker = "NYSE:GLD"
    trans.type = GMoney::BUY
    trans.public_is_valid_transaction?.should be_false    
    
    trans.portfolio = nil
    trans.ticker = nil
    trans.type = nil
    trans.public_is_valid_transaction?.should be_false        
    
    trans.portfolio = nil
    trans.ticker = "NYSE:GLD"
    trans.type = GMoney::BUY
    trans.public_is_valid_transaction?.should be_false        
    
    trans.portfolio = "1"
    trans.ticker = nil
    trans.type = GMoney::BUY
    trans.public_is_valid_transaction?.should be_false                
  end

  it "should save a transaction" do
    transaction = GMoney::Transaction.new
    transaction.portfolio = 9
    transaction.ticker = 'NASDAQ:GOOG'
    transaction.type = GMoney::BUY
    transaction.shares = 50
    transaction.price = 450.0
    transaction.commission = 20.0
    transaction.date = '2009-11-17T00:00:00.000'
    
    @gf_response.status_code = 200
    @gf_response.body = @new_transaction_feed

    transaction_save_helper(transaction)

    transaction_return = transaction.save
    
    transaction_return.id.should be_eql('http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions/NASDAQ:GOOG/transactions/12')
    transaction_return.commission.should be_eql(20.0)
    transaction_return.price.should be_eql(450.0)
    transaction_return.type.should be_eql('Buy')
  end

  it "should update a transaction when an @id is already set" do
    transaction = GMoney::Transaction.new
    transaction.portfolio = 9
    transaction.ticker = 'NASDAQ:GOOG'
    transaction.type = GMoney::BUY
    transaction.shares = 50
    transaction.price = 450.0
    transaction.commission = 20.0
    transaction.date = '2009-11-17T00:00:00.000'
    transaction.instance_variable_set("@id", "http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions/NASDAQ:GOOG/transactions/12")
    
    @gf_response.status_code = 201
    @gf_response.body = @new_transaction_feed

    transaction_save_helper(transaction)
    
    transaction.save
  end
 
  it "should raise a TransactionSaveError if the transaction type, ticker, or portfolio are not set" do
    transaction = GMoney::Transaction.new
    
    lambda { transaction.save }.should raise_error(GMoney::Transaction::TransactionSaveError, "You must include a portfolio id, ticker symbol, and transaction type ['Buy', 'Sell', 'Buy to Cover', 'Sell Short'] in order to create a transaction.")    
    
    transaction.portfolio = 9
    transaction.type = GMoney::BUY
    lambda { transaction.save }.should raise_error(GMoney::Transaction::TransactionSaveError, "You must include a portfolio id, ticker symbol, and transaction type ['Buy', 'Sell', 'Buy to Cover', 'Sell Short'] in order to create a transaction.")        
    
    transaction.portfolio = nil
    transaction.ticker = 'NASDAQ:GOOG'
    transaction.type = GMoney::BUY
    lambda { transaction.save }.should raise_error(GMoney::Transaction::TransactionSaveError, "You must include a portfolio id, ticker symbol, and transaction type ['Buy', 'Sell', 'Buy to Cover', 'Sell Short'] in order to create a transaction.")            
  end
  
  it "should give you a warning from Google if your transaction attributes are bad" do   
    transaction = GMoney::Transaction.new
    transaction.portfolio = 9
    transaction.ticker = 'asdfasd:asdfs' #invalid ticker
    transaction.type = GMoney::BUY
    transaction.shares = 50
    transaction.price = 450.0
    transaction.commission = 20.0
    transaction.date = '2009-11-17T00:00:00.000'    

    @gf_response.status_code = 400
    @gf_response.body = 'Some of the values submitted are not valid and have been ignored.'

    transaction_save_helper(transaction)
    
    lambda { transaction.save }.should raise_error(GMoney::Transaction::TransactionSaveError, "Some of the values submitted are not valid and have been ignored.")
    
  end

	it "should create a url out of a Portfolio id" do		
		#Set methods to public visibility for testing
	  GMoney::Transaction.send(:public, *GMoney::Transaction.private_instance_methods)
		trans = GMoney::Transaction.new
		transaction_string = trans.transaction_url("123/NASDAQ:GOOG/23")
		transaction_string.should be_eql("#{GMoney::GF_PORTFOLIO_FEED_URL}/123/positions/NASDAQ:GOOG/transactions/23")
	end
  
  def transaction_helper(id, options={})
    url = "#{GMoney::GF_PORTFOLIO_FEED_URL}/#{id.portfolio_id}/positions/#{id.position_id}/transactions/#{id.transaction_id}"

    GMoney::Transaction.should_receive(:transaction_url).with(id).and_return(url)

    GMoney::GFRequest.should_receive(:new).with(url).and_return(@gf_request)

    GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)
    
    GMoney::Transaction.find(id, options)
  end
  
  def transaction_delete_helper(url)
    GMoney::Transaction.should_receive(:transaction_url).and_return(url)

    GMoney::GFRequest.should_receive(:new).with(url, :method => :post, :headers => {"X-HTTP-Method-Override" => "DELETE"}).and_return(@gf_request)

    GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)
  end    
  
  def transaction_save_helper(transaction)
    currency_code = transaction.currency_code ? transaction.currency_code : 'USD'
  
      atom_string = "<?xml version='1.0'?>
      <entry xmlns='http://www.w3.org/2005/Atom'
            xmlns:gf='http://schemas.google.com/finance/2007'
            xmlns:gd='http://schemas.google.com/g/2005'>
            <gf:transactionData date='#{transaction.date}' shares='#{transaction.shares}' type='#{transaction.type}'>"

      atom_string += "<gf:commission><gd:money amount='#{transaction.commission}' currencyCode='#{currency_code}'/></gf:commission>" if transaction.commission
      atom_string += "<gf:price><gd:money amount='#{transaction.price}' currencyCode='#{currency_code}'/></gf:price>" if transaction.price
      atom_string += "</gf:transactionData></entry>"
    
    url = transaction.id ? transaction.id : "#{GMoney::GF_PORTFOLIO_FEED_URL}/#{transaction.portfolio}/positions/#{transaction.ticker}/transactions"

    headers = {"Content-Type" => "application/atom+xml"}
    headers["X-HTTP-Method-Override"] = "PUT" if transaction.id

    GMoney::GFRequest.should_receive(:new).with(url, :method => :post, :body => atom_string, :headers => headers).and_return(@gf_request)

    GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)    
  end  
end
