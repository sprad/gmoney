require 'rexml/document'

module GMoney
	class GFXmlParser
		def self.parse_portfolio(portfolio_feed)
			doc = REXML::Document.new(portfolio_feed)
			portfolios = []
			
			doc.elements.each('feed/entry') do |parsed_portfolio|
			  portfolio_name = parsed_portfolio.elements['title'].text
				currency_code  = parsed_portfolio.elements['gf:portfolioData'].attributes['currencyCode']
				
				portfolio = GMoney::Portfolio.new(portfolio_name, currency_code)
				portfolio.id  = parsed_portfolio.elements['id'].text				
				portfolio.updated  = parsed_portfolio.elements['updated'].text
				portfolio.feed_link = parsed_portfolio.elements['gd:feedLink'].attributes['href']
				
				parsed_portfolio.elements['gf:portfolioData'].attributes.each do |attr_name, attr_value|
					#Set the return percentages to a proper float value
				  attr_value = attr_value.to_f if attr_value.is_numeric?
					portfolio.instance_variable_set("@#{attr_name.camel_to_us}", attr_value)
				end
	
				portfolios << portfolio
			end
			portfolios
		end
	end	
end

#It looks like instance_variable_set might be interesting because it will allow
#you to set variables meta-programmatically, but won't allow you to override values, because
#there is not setter= method defined in portfolio for example for return1w... goodbye encapsulation

#portfolio.send("#{attr_name.camel_to_us}=", attr_value)
