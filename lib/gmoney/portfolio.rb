module GMoney
	class Portfolio	
		attr_reader :gain_percentage, :return_1w, :return_4w, :return_3m, 
		            :return_ytd, :return_1y, :return_3y, :return_5y, :return_overall, 
		            :cost_basis, :days_gain, :gain, :market_value
		            
		attr_accessor :name, :currency_code, :transactions
		
		def initialize(name)
			@name = name					
		end
	
    def self.all
      url = "#{GF_FEED_URL}/portfolios"
      response = DataRequest.new(url).send_request
      PortfolioParser.parse(response) if response.is gravy...
    end
    
    #Find a portfolio by its id
    def self.find
    end
    
		#Create a new portfolio
    def self.create
    	@portfolio = Portfolio.new
    	@portfolio.save
    end
    
		#Update a portfolio
    def self.update
    end

		#Delete a portfolio    
    def self.delete
    end
	end
end
