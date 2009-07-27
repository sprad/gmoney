module GMoney
	class Portfolio	
		attr_reader :gain_percentage, :return_1w, :return_4w, :return_3m, 
		            :return_ytd, :return_1y, :return_3y, :return_5y, :return_overall, 
		            :cost_basis, :days_gain, :gain, :market_value
		            
		attr_accessor :name, :currency_code, :transactions
		
		def initialize(name, currency_code, transactions=[], props={})		
			@name = name
			@currency_code = currency_code
			@transactions = transactions
			
			#should be an easy call to map the props hash to the instance variables
		end
		
    def self.all
      url = "#{GF_FEED_URL}/portfolios"
      response = DataRequest.new(url).send_request
      
      #GMoneyParser.parse_portfolio_data(response) if response.      
     	#have the xml parser return all portolios as portfolio objects
      #PortfolioParser.parse(response) if response.is gravy...
    end
    
    #Find a portfolio by its id
    def self.find
    	#have the xml parser return a portfolio object
    end
    
		#Create a new portfolio
    def self.create(name, currency_code = 'USD')
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
