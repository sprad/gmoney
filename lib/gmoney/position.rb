module GMoney
	class Position
		attr_accessor :transactions

		attr_reader :id, :updated, :title, :feed_link, :exchange, :symbol, :shares, 
								:full_name, :gain_percentage, :return1w, :return4w, :return3m, 
		            :return_ytd, :return1y, :return3y, :return5y, :return_overall, 
		            :cost_basis, :days_gain, :gain, :market_value
    
		def initialize
			@transactions = []
		end
	end
end
