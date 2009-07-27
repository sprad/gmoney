require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::Portfolio do
	before(:all) do
		@feed = File.read('spec/fixtures/default_portfolios_feed.xml')
	end

  it "should return all Portfolios" do   
		data_request = mock("GMoney::DataRequest")
	  GMoney::DataRequest.should_receive(:new).with('https://finance.google.com/finance/feeds/default/portfolios').and_return(data_request)
		data_request.should_receive(:send_request).and_return(@feed)
		GMoney::Portfolio.all.should be_eql(@feed)
		#GMoney::Portfolio.all.should == {}
  end
end
