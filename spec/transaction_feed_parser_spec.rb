require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::TransactionFeedParser do
  before(:all) do
    feed = File.read('spec/fixtures/transactions_feed_for_GOOG.xml')
    @transactions = GMoney::TransactionFeedParser.parse_transaction_feed(feed)
  end
  it "should create Transaction objects out of transaction feeds" do
    @transactions.each do |transaction|
      transaction.should be_instance_of(GMoney::Transaction)
    end
  end
  
  it "should return an Array of Transaction objects equal to the size of Transaction entries" do    
    @transactions.size.should be_eql(4)
  end
  
  it "should create Transaction objects with valid numeric data types" do
    @transactions.each do |transaction|
      transaction.public_methods(false).each do |pm|      
        if (['shares', 'commission', 'price'].include? pm) && !(pm.include?('='))
          return_val = transaction.send(pm)
          return_val.should be_instance_of(Float) if return_val
        end
      end
    end
  end
end
