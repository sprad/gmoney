require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::Transaction do
	before(:all) do
		@goog_feed = File.read('spec/fixtures/transactions_feed_for_GOOG.xml')
	end
	
	before(:each) do
		@url = 'https://finance.google.com/finance/feeds/default/portfolios/9/positions/NASDAQ:GOOG/transactions'	
		
		@gf_request = GMoney::GFRequest.new(@url)
		@gf_request.method = :get		
		
		@gf_response = GMoney::GFResponse.new
		@gf_response.status_code = 200
		@gf_response.body = @goog_feed
	end
	
	it "should return all Tranasactions when the status code is 200" do
		transactions = transaction_helper(@url)
	
		transactions.size.should be_eql(4)
		transactions[1].commission.should be_eql(12.75)
		transactions[1].notes.should be_eql('Buy some more Google.')
	end
	
	it "should raise an error when the status code is not 200" do
		@gf_response.status_code = 404
  
		lambda { transaction_helper(@url) }.should raise_error(GMoney::Transaction::TransactionRequestError)	
	end

=begin TODO - create a method that retreives individual transactions
  it "should return a specific transactions is the request a specific transactions" do
=end		
	
  def transaction_helper(url)
		GMoney::GFSession.should_receive(:auth_token).and_return('toke')

	  GMoney::GFRequest.should_receive(:new).with(url, :headers => {"Authorization" => "GoogleLogin auth=toke"}).and_return(@gf_request)

		GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)
		
	 	GMoney::Transaction.find_by_url(url)
  end
end
