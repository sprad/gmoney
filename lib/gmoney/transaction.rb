module GMoney
  class Transaction
    class TransactionRequestError < StandardError; end
    
    attr_reader :id, :updated, :title

    attr_accessor :type, :date, :shares, :notes, :commission, :price
    
    def self.find(id, options={})   
      find_by_url("#{GF_PORTFOLIO_FEED_URL}/#{id.portfolio_id}/positions/#{id.position_id}/transactions/#{id.transaction_id}", options)    
    end    
    
    def self.find_by_url(url, options={})
      transactions = []
      
      response = GFService.send_request(GFRequest.new(url, :headers => {"Authorization" => "GoogleLogin auth=#{GFSession.auth_token}"}))
      
      if response.status_code == HTTPOK
        transactions = TransactionFeedParser.parse_transaction_feed(response.body)
      else
        raise TransactionRequestError, response.body
      end
      
      return transactions[0] if transactions.size == 1
      
      transactions
    end
    
    private_class_method :find_by_url
  end
end
