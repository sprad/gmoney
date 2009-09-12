module GMoney
	class Portfolio	
		attr_accessor :title, :currency_code
		            	
		attr_reader :id, :feed_link, :updated, :gain_percentage, :return1w, :return4w, :return3m, 
		            :return_ytd, :return1y, :return3y, :return5y, :return_overall, 
		            :cost_basis, :days_gain, :gain, :market_value, :positions
		
		def initialize(title, currency_code)		
			@title = title
			@currency_code = currency_code
		end
		
		#TODO alias .all with find(:all)
    def self.all(options = {})
      url = "#{GF_FEED_URL}/portfolios"
      url += "?returns=true" if options[:with_returns]
      
      response = GFService.send_request(GFRequest.new(url, :headers => {"Authorization" => "GoogleLogin auth=#{Session.auth_token}"}))
      
      #GMoneyParser.parse_portfolio_data(response) if response.      
     	#have the xml parser return all portolios as portfolio objects
      #PortfolioParser.parse(response) if response.is gravy...
    end
    
    #Find a portfolio by its id
    def self.find
    	#have the xml parser return a portfolio object
    end
    
		#Create a new portfolio
    def self.create(title, currency_code = 'USD')
			#we have a data_request object, should we also have a data_"creation" object

			#take in the properties
			#send them to the correct url in the correct format
			#return the portfolio object
    end
    
		#Update a portfolio
    def self.update
			#take in the properties
			#send them to the correct url in the correct format
			#return the portfolio object
    end

		#Delete a portfolio    
    def self.delete
 			#take in the properties
			#send delete to the correct url
    end
	end
end
