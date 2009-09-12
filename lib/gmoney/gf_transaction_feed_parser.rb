module GMoney
	class GFTransactionFeedParser
		def self.parse_transaction_feed(transaction_feed)
			doc = REXML::Document.new(transaction_feed)
			transactions = []

			doc.elements.each('feed/entry') do |parsed_transaction|
				transaction = GMoney::Transaction.new
				transaction_data = parsed_transaction.elements['gf:transactionData']

				transaction.instance_variable_set("@id", parsed_transaction.elements['id'].text)
				transaction.instance_variable_set("@title", parsed_transaction.elements['title'].text)
				transaction.instance_variable_set("@updated", DateTime.parse(parsed_transaction.elements['updated'].text))
				
				transaction_data.attributes.each do |attr_name, attr_value|
				  attr_value = attr_value.to_f if attr_value.is_numeric?
					transaction.instance_variable_set("@#{attr_name.camel_to_us}", attr_value)
				end				

				transaction_data.elements.each do |cp|
					transaction.instance_variable_set("@#{cp.name.camel_to_us}", cp.elements['gd:money'].attributes['amount'].to_f)
				end
	
				transactions << transaction
			end
			transactions
		end
	end	
end
