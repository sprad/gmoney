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
end
