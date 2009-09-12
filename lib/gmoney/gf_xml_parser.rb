require 'rexml/document'

module GMoney
	class GFXmlParser
		def self.parse_portfolio(portfolio_feed)
			doc = REXML::Document.new(portfolio_feed)
			portfolios = []
			
			doc.elements.each('feed/entry') do |parsed_portfolio|
			  portfolio_name = parsed_portfolio.elements['title'].text
				currency_code  = parsed_portfolio.elements['gf:portfolioData'].attributes['currencyCode']
				
				#TODO - have someone peer review this.  Is it bad practice to use instance_variable_set because
				#it breaks encapsulation? (Even though it actually enhances the Portfolio classes encapsulation
				#by not allowing users to set attributes that should be read only (i.e. id, updated, return1w))
				portfolio = GMoney::Portfolio.new(portfolio_name, currency_code)
				portfolio.instance_variable_set("@id", parsed_portfolio.elements['id'].text)
				portfolio.instance_variable_set("@updated", parsed_portfolio.elements['updated'].text)
				portfolio.instance_variable_set("@feed_link", parsed_portfolio.elements['gd:feedLink'].attributes['href'])
				
				portfolio_data = parsed_portfolio.elements['gf:portfolioData']
				
				portfolio_data.attributes.each do |attr_name, attr_value|
					#Set the return percentages to a proper float value
				  attr_value = attr_value.to_f if attr_value.is_numeric?
					portfolio.instance_variable_set("@#{attr_name.camel_to_us}", attr_value)
				end				

				#TODO - This is only going to work for USD for now.  Need to updated to make a "Money" object to store amount and currency code.
				portfolio_data.elements.each do |cg|
					portfolio.instance_variable_set("@#{cg.name.camel_to_us}", cg.elements['gd:money'].attributes['amount'].to_f)
				end			
	
				portfolios << portfolio
			end			
			portfolios
		end
	end	
end
