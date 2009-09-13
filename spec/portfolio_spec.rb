require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::Portfolio do
	before(:all) do
		@default_feed = File.read('spec/fixtures/default_portfolios_feed.xml')
		@feed_with_returns = File.read('spec/fixtures/portfolio_feed_with_returns.xml')
		@empty_feed = File.read('spec/fixtures/empty_portfolio_feed.xml')
		@portfolio_9_feed = File.read('spec/fixtures/portfolio_9_feed.xml')
	end
	
	before(:each) do
		@url = 'https://finance.google.com/finance/feeds/default/portfolios'
	
		@gf_request = GMoney::GFRequest.new(@url)
		@gf_request.method = :get		
		
		@gf_response = GMoney::GFResponse.new
		@gf_response.status_code = 200
		@gf_response.body = @default_feed
		@positions = []
	end	

  it "should return all Portfolios when status_code is 200" do   
		@gf_response.body = @default_feed
		portfolios = portfolio_helper(@url)
		
		portfolios.size.should be_eql(3)
  end

  it "should return a portfolio with returns data is :with_returns == true" do
		@url = 'https://finance.google.com/finance/feeds/default/portfolios?returns=true'
		@gf_response.body = @feed_with_returns

		portfolios = portfolio_helper(@url, {:with_returns => true})
		
		portfolios.size.should be_eql(3)
		portfolios[0].cost_basis.should be_eql(2500.00)
		portfolios[0].gain_percentage.should be_eql(28.3636)
		portfolios[0].return4w.should be_eql(-0.1670616114)

		portfolios[2].cost_basis.should be_nil
  end
  
  it "should raise an error if the portfolio request does not return an OK status code" do
		@gf_response.status_code = 404
  
		lambda { portfolio_helper(@url) }.should raise_error(GMoney::Portfolio::PortfolioRequestError)
  end
  
  it "should return an Array with only the default 'My Portfolio' portfolio when a user does not define his own portfolios" do
		@gf_response.body = @empty_feed
		portfolios = portfolio_helper(@url)
		
		portfolios.size.should be_eql(1)  
		portfolios[0].title.should be_eql('My Portfolio')
  end

=begin TODO - create a method that retreives individual portfolios
  it "should return a specific portfolio is the request a specific portfolio" do
  	@url += '/9'
  	@gf_request.url = @url
  	
		@gf_response.body = @portfolio_9_feed
		portfolios = portfolio_helper(@url)
		
		portfolios.size.should be_eql(1)  
		portfolios[0].title.should be_eql('GMoney Test') 	
  end
=end

  def portfolio_helper(url, options = {})
		GMoney::GFSession.should_receive(:auth_token).and_return('toke')

	  GMoney::GFRequest.should_receive(:new).with(url, :headers => {"Authorization" => "GoogleLogin auth=toke"}).and_return(@gf_request)

		GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)
		
		position_urls = get_position_urls(@gf_response.body)
		
		position_urls.each do |position_url|
		  GMoney::Position.should_receive(:find_by_url).with(position_url, {:with_returns => options[:with_returns]}).any_number_of_times.and_return(@positions)				
		end
	  	
	 	GMoney::Portfolio.all(options)
  end
  
  def get_position_urls(feed)
		doc = REXML::Document.new(feed)
		feed_links = []			

		doc.elements.each('feed/entry') do |parsed_entry|
			feed_links << parsed_entry.elements['gd:feedLink'].attributes['href']
		end
		feed_links
  end
end
