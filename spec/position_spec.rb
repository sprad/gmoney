require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::Position do
	before(:all) do
		@default_feed = File.read('spec/fixtures/positions_feed_for_portfolio_9.xml')
		@feed_with_returns = File.read('spec/fixtures/positions_feed_for_portfolio_9r.xml')
		@empty_feed = File.read('spec/fixtures/positions_feed_for_portfolio_14.xml')
	end
	
	before(:each) do
		@url = 'https://finance.google.com/finance/feeds/default/portfolios/9/positions'
	
		@gf_request = GMoney::GFRequest.new(@url)
		@gf_request.method = :get		
		
		@gf_response = GMoney::GFResponse.new
		@gf_response.status_code = 200
		@gf_response.body = @defaul_feed
		@transactions = []
	end	

  it "should return all Positions when status_code is 200" do   
		@gf_response.body = @default_feed
		positions = position_helper(@url)
		
		positions.size.should be_eql(5)
  end

  it "should return a position with returns data is :with_returns == true" do
		@gf_response.body = @feed_with_returns

		positions = position_helper(@url, {:with_returns => true})
		
		positions.size.should be_eql(5)
		positions[0].cost_basis.should be_eql(615.00)
		positions[0].gain_percentage.should be_eql(0.1182926829)
		positions[0].return4w.should be_eql(0.09390243902)

		positions[4].days_gain.should be_eql(28.500375)
  end
  
  it "should raise an error if the position request does not return an OK status code" do
		@gf_response.status_code = 404
  
		lambda { position_helper(@url) }.should raise_error(GMoney::Position::PositionRequestError)
  end

=begin TODO - create a method that retreives individual positions
  it "should return a specific position is the request a specific position" do
  end
=end

  def position_helper(url, options = {})
		GMoney::GFSession.should_receive(:auth_token).and_return('toke')

		send_url = options[:with_returns] ? (url + '?returns=true') : url

	  GMoney::GFRequest.should_receive(:new).with(send_url, :headers => {"Authorization" => "GoogleLogin auth=toke"}).and_return(@gf_request)

		GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)
		
		transaction_urls = get_transaction_urls(@gf_response.body)
		
		transaction_urls.each do |transaction_url|
		  GMoney::Transaction.should_receive(:find_by_url).with(transaction_url).any_number_of_times.and_return(@transactions)
		end
	  	
	 	GMoney::Position.find_by_url(url, options)
  end
  
  def get_transaction_urls(feed)
		doc = REXML::Document.new(feed)
		feed_links = []			

		doc.elements.each('feed/entry') do |parsed_entry|
			feed_links << parsed_entry.elements['gd:feedLink'].attributes['href']
		end
		feed_links
  end
end
