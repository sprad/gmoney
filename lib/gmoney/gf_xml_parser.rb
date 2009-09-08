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
				
				#TODO Does send totally kill performance?
				parsed_portfolio.elements['gf:portfolioData'].attributes.each do |attr_name, attr_value|
					portfolio.send("#{attr_name.camel_to_us}=", attr_value)					
				end
	
				portfolios << portfolio
			end
			portfolios
		end
	end	
end
