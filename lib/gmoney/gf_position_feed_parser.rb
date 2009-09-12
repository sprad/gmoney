module GMoney
	class GFPositionFeedParser
		def self.parse_position_feed(position_feed)
			doc = REXML::Document.new(position_feed)
			positions = []
			
			doc.elements.each('feed/entry') do |parsed_position|
				position = GMoney::Position.new
				position_data = parsed_position.elements['gf:positionData']
				symbol_data = parsed_position.elements['gf:symbol']				

				position.instance_variable_set("@id", parsed_position.elements['id'].text)
				position.instance_variable_set("@title", parsed_position.elements['title'].text)
				position.instance_variable_set("@updated", DateTime.parse(parsed_position.elements['updated'].text))
				position.instance_variable_set("@feed_link", parsed_position.elements['gd:feedLink'].attributes['href'])
				
				position_data.attributes.each do |attr_name, attr_value|
				  attr_value = attr_value.to_f if attr_value.is_numeric?
					position.instance_variable_set("@#{attr_name.camel_to_us}", attr_value)
				end				

				position_data.elements.each do |cg|
					position.instance_variable_set("@#{cg.name.camel_to_us}", cg.elements['gd:money'].attributes['amount'].to_f)
				end			
				
				symbol_data.attributes.each do |attr_name, attr_value|
				  attr_value = attr_value.to_f if attr_value.is_numeric?
					position.instance_variable_set("@#{attr_name.camel_to_us}", attr_value)					
				end							
	
				positions << position
			end
			positions
		end
	end	
end
