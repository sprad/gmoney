require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::Portfolio do
  before(:all) do
    @default_feed = File.read('spec/fixtures/default_portfolios_feed.xml')
    @feed_with_returns = File.read('spec/fixtures/portfolio_feed_with_returns.xml')
    @empty_feed = File.read('spec/fixtures/empty_portfolio_feed.xml')
    @portfolio_9_feed = File.read('spec/fixtures/portfolio_9_feed.xml')    
    @new_portfolio_feed = File.read('spec/fixtures/new_portfolio_feed.xml')
    @updated_portfolio_feed = File.read('spec/fixtures/updated_portfolio_feed.xml')        
  end
  
  before(:each) do
    @url = "#{GMoney::GF_URL}/feeds/default/portfolios"
  
    @gf_request = GMoney::GFRequest.new(@url)
    @gf_request.method = :get
    
    @gf_response = GMoney::GFResponse.new
    @gf_response.status_code = 200
    @gf_response.body = @default_feed
    @positions = nil
  end
  
  it "should have return a human readable (i.e. non-url) portfolio id" do
    @gf_response.body = @default_feed

    portfolios = portfolio_helper(@url)    
    
    portfolios[0].pid.should be_eql("8")
    portfolios[1].pid.should be_eql("9")
    portfolios[2].pid.should be_eql("3")
  end

  it "should return all Portfolios when status_code is 200" do   
    @gf_response.body = @default_feed
    portfolios = portfolio_helper(@url)
    
    portfolios.size.should be_eql(3)
  end

  it "should return a portfolio with returns data is :returns == true" do
    @url = "#{GMoney::GF_URL}/feeds/default/portfolios?returns=true"
    @gf_response.body = @feed_with_returns

    portfolios = portfolio_helper(@url, :all, {:returns => true})
    
    portfolios.size.should be_eql(3)
    portfolios[0].cost_basis.should be_eql(2500.00)
    portfolios[0].gain_percentage.should be_eql(28.3636)
    portfolios[0].return4w.should be_eql(-0.1670616114)
    portfolios[2].cost_basis.should be_nil
  end
  
  it "should raise an error if the portfolio request does not return an OK status code" do
    @gf_response.status_code = 401  
    lambda { portfolio_helper(@url) }.should raise_error(GMoney::Portfolio::PortfolioRequestError)
  end
  
  it "should raise an error with an error message when the user requests an invalid portfolio" do
    @url += '/235234'
    @gf_response.status_code = 404
    @gf_response.body = "No portfolio exists with pid 235234"

    lambda { portfolio_helper(@url, 235234) }.should raise_error(GMoney::Portfolio::PortfolioRequestError, @gf_response.body)
  end  
  
  it "should return the default 'My Portfolio' portfolio when a user has not defined his own portfolios" do
    @gf_response.body = @empty_feed
    portfolio = portfolio_helper(@url)    
    portfolio.title.should be_eql('My Portfolio')
  end

  it "should return a specific portfolio if the user requests a specific portfolio" do
    @url += '/9'
    @gf_request.url = @url
    
    @gf_response.body = @portfolio_9_feed
    portfolio = portfolio_helper(@url, 9)    
    portfolio.title.should be_eql('GMoney Test')  
  end
  
  it "should grab the latest positions when :refresh is used." do
    @url += '/9'
    @gf_request.url = @url
    @positions = [GMoney::Position.new, GMoney::Position.new]
    
    @gf_response.body = @portfolio_9_feed
    portfolio = portfolio_helper(@url, 9)

    GMoney::Position.should_receive(:find).with("9", {:refresh => true}).and_return(@positions)
    
    portfolio.positions(:refresh => true).size.should be_eql(2)
  end
  
  it "should use the cached portfolios when :refresh is not used (and the portfolios have already been set)" do
    @url += '/9'
    @gf_request.url = @url
    @positions = [GMoney::Position.new, GMoney::Position.new]
    
    @gf_response.body = @portfolio_9_feed
    portfolio = portfolio_helper(@url, 9, :eager => true)
    
    GMoney::Position.should_not_receive(:find).with(9, :eager => true)
    portfolio.positions.size.should be_eql(2)
  end  
  
  it "should delete portfolios using a class method and id" do
    @gf_request = GMoney::GFRequest.new(@url)
    @gf_request.method = :delete
    
    @gf_response = GMoney::GFResponse.new
    @gf_response.status_code = 200
    
    portfolio_delete_helper("#{@url}/19")
    
    GMoney::Portfolio.delete(19).should be_nil
  end
  
  it "should delete portfolios by calling delete on an instance of a portfolio" do
    @gf_request = GMoney::GFRequest.new(@url)
    @gf_request.method = :delete
    
    @gf_response = GMoney::GFResponse.new
    @gf_response.status_code = 200
    
    portfolio = GMoney::Portfolio.new
    portfolio.instance_variable_set("@id", "#{@url}/24")
     
    portfolio_delete_helper("#{@url}/24")

    portfolio_return = portfolio.delete
    portfolio_return.should be_eql(portfolio)
    portfolio_return.frozen?.should be_true
  end
  
  it "should raise a PortfolioDeleteError when there is an attempt to delete an portfolio that doesn't exist')" do
    @gf_request = GMoney::GFRequest.new(@url)
    @gf_request.method = :delete
    
    @gf_response = GMoney::GFResponse.new
    @gf_response.status_code = 400
    @gf_request.body = "Invalid portfolio ID."

    portfolio_delete_helper("#{@url}/asdf")

    lambda { GMoney::Portfolio.delete("asdf") }.should raise_error(GMoney::Portfolio::PortfolioDeleteError, @gf_response.body)
  end
  
  it "should save a portfolio" do
    portfolio = GMoney::Portfolio.new
    portfolio.title = "New Portfolio"
    
    @gf_response.status_code = 200
    @gf_response.body = @new_portfolio_feed

    portfolio_save_helper(portfolio)

    portfolio_return = portfolio.save
    
    portfolio_return.id.should be_eql("#{GMoney::GF_URL}/feeds/user@example.com/portfolios/38")
    portfolio_return.title.should be_eql("New Portfolio")
  end
  
  it "should update a portfolio when an @id is already set" do
    portfolio = GMoney::Portfolio.new
    portfolio.title = "New Portfolio"
    portfolio.instance_variable_set("@id", "http://finance.google.com/finance/feeds/user@example.com/portfolios/38")
    
    @gf_response.status_code = 201
    @gf_response.body = @new_portfolio_feed

    portfolio_save_helper(portfolio)
    
    portfolio.save
  end
  
  it "should raise a PortfolioSaveError if the portfolio title is empty or nil" do
    portfolio = GMoney::Portfolio.new
    lambda { portfolio.save }.should raise_error(GMoney::Portfolio::PortfolioSaveError, 'Portfolios must have a title')    
    
    portfolio.title = ""
    lambda { portfolio.save }.should raise_error(GMoney::Portfolio::PortfolioSaveError, 'Portfolios must have a title')        
    
    portfolio.title = "   "
    lambda { portfolio.save }.should raise_error(GMoney::Portfolio::PortfolioSaveError, 'Portfolios must have a title')            
  end  

  it "should raise a PortfolioSaveError if a portfolio with the same title already exists" do
    portfolio = GMoney::Portfolio.new
    portfolio.title = "New Portfolio" #already exists
    
    @gf_response.status_code = 400
    @gf_response.body = 'A Portfolio with this name already exists.'

    portfolio_save_helper(portfolio)

    lambda { portfolio.save }.should raise_error(GMoney::Portfolio::PortfolioSaveError, 'A Portfolio with this name already exists.')
  end

  def portfolio_helper(url, id = nil, options = {})    
    GMoney::GFRequest.should_receive(:new).with(url).and_return(@gf_request)

    GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)
    
    if options[:eager]
      feed_ids = get_feed_ids(@gf_response.body)   
      feed_ids.each do |feed_id|
        GMoney::Position.should_receive(:find).with(feed_id.portfolio_feed_id, options).any_number_of_times.and_return(@positions)        
      end
    end
      
    portfolios = id ? GMoney::Portfolio.find(id, options) : GMoney::Portfolio.all(options)
  end
  
  def portfolio_delete_helper(url)    
    GMoney::GFRequest.should_receive(:new).with(url, :method => :post, :headers => {"X-HTTP-Method-Override" => "DELETE"}).and_return(@gf_request)

    GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)
  end
  
  def portfolio_save_helper(portfolio)
    title = portfolio.title
    currency_code = portfolio.currency_code ? portfolio.currency_code : 'USD'
  
    atom_string = "<?xml version='1.0'?><entry xmlns='http://www.w3.org/2005/Atom' xmlns:gf='http://schemas.google.com/finance/2007' xmlns:gd='http://schemas.google.com/g/2005'><title type='text'>#{title}</title> <gf:portfolioData currencyCode='#{currency_code}'/></entry>"
    
    url = portfolio.id ? portfolio.id : GMoney::GF_PORTFOLIO_FEED_URL

    headers = {"Content-Type" => "application/atom+xml"}
    headers["X-HTTP-Method-Override"] = "PUT" if portfolio.id

    GMoney::GFRequest.should_receive(:new).with(url, :method => :post, :body => atom_string, :headers => headers).and_return(@gf_request)

    GMoney::GFService.should_receive(:send_request).with(@gf_request).and_return(@gf_response)    
  end
end
