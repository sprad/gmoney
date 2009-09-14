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
end
