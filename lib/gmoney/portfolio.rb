module GMoney
  class Portfolio 
    class PortfolioRequestError < StandardError;end
    class PortfolioDeleteError < StandardError;end
    class PortfolioSaveError < StandardError;end    
  
    attr_accessor :title, :currency_code
                  
    attr_reader :id, :feed_link, :updated, :gain_percentage, :return1w, :return4w, :return3m, 
                :return_ytd, :return1y, :return3y, :return5y, :return_overall, 
                :cost_basis, :days_gain, :gain, :market_value
     
    def pid
      @id.portfolio_feed_id
    end

    def self.all(options = {})
      retreive_portfolios(:all, options)
    end
    
    def self.find(id, options = {})
      retreive_portfolios(id, options)
    end
    
    def positions(options = {})
      if options[:refresh]
        @positions = Position.find(pid, options)
      else
        @positions ||= Position.find(pid, options)
      end
      
      @positions.is_a?(Array) ? @positions : [@positions]
    end
    
    def save
      save_portfolio
    end
    
    def self.delete(id)
      delete_portfolio(id)
    end
    
    def delete
      Portfolio.delete(pid)
      freeze
    end
      
    def self.retreive_portfolios(id, options = {})
      url = GF_PORTFOLIO_FEED_URL
      url += "/#{id}" if id != :all
      url += "?returns=true" if options[:returns]
      portfolios = []
      
      response = GFService.send_request(GFRequest.new(url, :headers => {"Authorization" => "GoogleLogin auth=#{GFSession.auth_token}"}))

      if response.status_code == HTTPOK
        portfolios = PortfolioFeedParser.parse_portfolio_feed(response.body)
      else
        raise PortfolioRequestError, response.body
      end

      portfolios.each { |p| p.instance_variable_set("@positions", p.positions(options))} if options[:eager]
      
      return portfolios[0] if portfolios.size == 1
      
      portfolios        
    end
    
    def save_portfolio
      raise PortfolioSaveError, 'Portfolios must have a title' if @title.blank?

      @currency_code ||= 'USD'
      
      #Rcov hates multi-line strings and I hate red on my test coverage report.
      atom_string = "<?xml version='1.0'?><entry xmlns='http://www.w3.org/2005/Atom' xmlns:gf='http://schemas.google.com/finance/2007' xmlns:gd='http://schemas.google.com/g/2005'><title type='text'>#{title}</title> <gf:portfolioData currencyCode='#{currency_code}'/></entry>"
      
      url = @id ? @id : GF_PORTFOLIO_FEED_URL

      #Some firewalls block HTTP PUT messages. To get around this, you can include a 
      #X-HTTP-Method-Override: PUT header in a POST request
      headers = {"Authorization" => "GoogleLogin auth=#{GFSession.auth_token}", "Content-Type" => "application/atom+xml"}     
      headers["X-HTTP-Method-Override"] = "PUT" if @id #if there is already an @id defined then we are updating a portfolio
      
      request = GFRequest.new(url, :method => :post, :body => atom_string, :headers => headers)
     
      response = GFService.send_request(request)

      if response.status_code == HTTPCreated || response.status_code == HTTPOK
        portfolio = PortfolioFeedParser.parse_portfolio_feed(response.body)[0]
        self.instance_variable_set("@id", portfolio.id) if response.status_code == HTTPCreated
      else
        raise PortfolioSaveError, response.body
      end
      portfolio
    end
   
    #Some firewalls block HTTP DELETE messages. To get around this, you can include a 
    #X-HTTP-Method-Override: DELETE header in a POST request   
    def self.delete_portfolio(id)
      url = "#{GF_PORTFOLIO_FEED_URL}/#{id}"
      response = GFService.send_request(GFRequest.new(url, :method => :post, :headers => {"Authorization" => "GoogleLogin auth=#{GFSession.auth_token}", "X-HTTP-Method-Override" => "DELETE"}))
      raise PortfolioDeleteError, response.body if response.status_code != HTTPOK
    end
    
    private :save_portfolio
    private_class_method :retreive_portfolios, :delete_portfolio
  end
end
