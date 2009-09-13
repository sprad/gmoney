module GMoney
	class GFTransactionFeedParser < GFFeedParser
		def self.parse_transaction_feed(transaction_feed)
			parse_feed(transaction_feed, Transaction, {:feed_link => false})
		end		
	end	
end


