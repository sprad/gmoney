require File.join(File.dirname(__FILE__), '/spec_helper')

describe String do
  it "should convert camel cased strings to strings with underscores" do
    'CamelCase'.camel_to_us.should be_eql('camel_case')
    'CamelCamelCase'.camel_to_us.should be_eql('camel_camel_case')
    'Camel2Camel2Case'.camel_to_us.should be_eql('camel2_camel2_case')
    'getHTTPResponseCode'.camel_to_us.should be_eql('get_http_response_code') 
    'get2HTTPResponseCode'.camel_to_us.should be_eql('get2_http_response_code') 
    'HTTPResponseCode'.camel_to_us.should be_eql('http_response_code')    
    'HTTPResponseCodeXYZ'.camel_to_us.should be_eql('http_response_code_xyz')
    'returnYTD='.camel_to_us.should be_eql('return_ytd=')   
    'return_ytd='.camel_to_us.should be_eql('return_ytd=')        
  end
  
  it "should be able to detect if its contents are numeric" do
    '0'.is_numeric?.should be_true
    '0.0'.is_numeric?.should be_true
    '1'.is_numeric?.should be_true
    '-1'.is_numeric?.should be_true
    '-0.3423'.is_numeric?.should be_true
    '234.2352'.is_numeric?.should be_true
    '-234.2352'.is_numeric?.should be_true
    '-0.2352'.is_numeric?.should be_true
    '-0.2352'.is_numeric?.should be_true
    '-.2352'.is_numeric?.should be_true   
    
    'a'.is_numeric?.should be_false
    'cat'.is_numeric?.should be_false
    '-.23s52'.is_numeric?.should be_false
    '0.0s'.is_numeric?.should be_false    
    's0.0'.is_numeric?.should be_false
    's1'.is_numeric?.should be_false    
    '1s1'.is_numeric?.should be_false       
    '1s'.is_numeric?.should be_false            
    '@'.is_numeric?.should be_false       
    '$123.23'.is_numeric?.should be_false           
    '.'.is_numeric?.should be_false               
  end
  
  it "should be able to parse a portfolio id from an portfolio feed url" do
    "http://finance.google.com/finance/feeds/user@example.com/portfolios/9".portfolio_feed_id.should be_eql("9")
  end
  
  it "should be able to parse a position id from an position feed url" do
    "http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions/NASDAG:GOOG".position_feed_id.should be_eql("9/NASDAG:GOOG")
  end  
  
  it "should be able to parse a transaction id from an transaction feed url" do
    "http://finance.google.com/finance/feeds/user@example.com/portfolios/9/positions/NASDAG:GOOG/transactions/12".transaction_feed_id.should be_eql("9/NASDAG:GOOG/12")
    "http://finance.google.com/finance/feeds/user@example.com/portfolios/12/positions/NYSE:GLD/transactions/3".transaction_feed_id.should be_eql("12/NYSE:GLD/3")    
  end    
  
  it "should be able to parse a portfolio id out of a string" do
    1.portfolio_id.should be_eql("1")
    "1".portfolio_id.should be_eql("1")
    lambda { "asdf".portfolio_id }.should raise_error(String::PortfolioParseError)
    lambda { "123/NASDAQ:GOOG/2134/23".portfolio_id }.should raise_error(String::PortfolioParseError)    
    "124".portfolio_id.should be_eql("124")
    "1/NASDAQ:GOOG".portfolio_id.should be_eql("1") 
    "123/NASDAQ:GOOG".portfolio_id.should be_eql("123")
    "123/NASDAQ:GOOG/23".portfolio_id.should be_eql("123")
  end
  
  it "should be able to parse a position id out of a string" do
    1.position_id.should be_eql("")
    "1".position_id.should be_eql("")
    lambda { "asdf".position_id }.should raise_error(String::PositionParseError)
    lambda {"123/NASDAQ:GOOG/2134/23".position_id}.should raise_error(String::PositionParseError)
    "1/NASDAQ:GOOG".position_id.should be_eql("NASDAQ:GOOG")
    "123/NASDAQ:GOOG".position_id.should be_eql("NASDAQ:GOOG")   
    "123/NASDAQ:GOOG/23".position_id.should be_eql("NASDAQ:GOOG")
  end
  
  it "should be able to parse a transaction id out of a string" do  
    lambda { 1.transaction_id }.should raise_error(String::TransactionParseError)
    lambda { "1".transaction_id }.should raise_error(String::TransactionParseError)
    lambda { "asdf".transaction_id }.should raise_error(String::TransactionParseError)
    "1/NASDAQ:GOOG".transaction_id.should be_eql("")
    lambda {"123/NASDAQ:GOOG/asdf".transaction_id}.should raise_error(String::TransactionParseError)
    lambda {"123/NASDAQ:GOOG/2134/23".transaction_id}.should raise_error(String::TransactionParseError)
    "123/NASDAQ:GOOG/23".transaction_id.should be_eql("23")
  end
  
  it "should be able to detect blank strings" do  
    nil.blank?.should be_true
    "".blank?.should be_true
    "    ".blank?.should be_true    
    "  a  ".blank?.should be_false
    "234".blank?.should be_false  
  end
end
