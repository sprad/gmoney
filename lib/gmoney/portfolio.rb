module GMoney
  class Portfolio 
    class PortfolioRequestError < StandardError;end
    class PortfolioDeleteError < StandardError;end
  
    attr_accessor :title, :currency_code
                  
    attr_reader :id, :feed_link, :updated, :gain_percentage, :return1w, :return4w, :return3m, 
                :return_ytd, :return1y, :return3y, :return5y, :return_overall, 
                :cost_basis, :days_gain, :gain, :market_value
     
    def self.all(options = {})
      retreive_portfolios(:all, options)
    end
    
    def self.find(id, options = {})
      retreive_portfolios(id, options)
    end
    
    def positions(options = {})
      if options[:refresh]
        @positions = Position.find(@id.portfolio_feed_id, options)
      else
        @positions ||= Position.find(@id.portfolio_feed_id, options)
      end
      
      @positions.is_a?(Array) ? @positions : [@positions]
    end
    
    def self.delete(id)
      delete_portfolio(id)
    end
    
    def destroy
      Portfolio.delete(@id.portfolio_feed_id)
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
   
    #If you are working behind some firewalls HTTP DELETE request won't work.
    #To overcome this problem the google doc say to use a post request with
    #the X-HTTP-Method-Override set to "DELETE"    
    def self.delete_portfolio(id)
      url = "#{GF_PORTFOLIO_FEED_URL}/#{id}"
      response = GFService.send_request(GFRequest.new(url, :method => :post, :headers => {"Authorization" => "GoogleLogin auth=#{GFSession.auth_token}", "X-HTTP-Method-Override" => "DELETE"}))
      raise PortfolioDeleteError, response.body if response.status_code != HTTPOK
    end
    
    private_class_method :retreive_portfolios, :delete_portfolio
  end
end
