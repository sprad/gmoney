module GMoney
  # = TransactionFeedParser
  #
  # Parses Transaction feeds returned from the Google Finance API
  #
  class TransactionFeedParser < FeedParser
    def self.parse_transaction_feed(transaction_feed)
      parse_feed(transaction_feed, Transaction, {:feed_link => false})
    end   
  end 
end


