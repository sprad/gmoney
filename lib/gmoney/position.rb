module GMoney
  # = Position
  #
  # The Google Finace API allows users to view position information
  # for the securities (i.e. Positions) in their portfolios.
  # To read a position use the following code:
  #
  # > positions = GMoney::Position.find(9) #returns all of a user's positions within a given portfolio, i.e. Portfolio "9"
  # > position = GMoney::Position.find("9/NASDAQ:GOOG") #returns a specific position within a given portfolio
  #
  class Position
    # = PositionRequestError
    # Invalid request actions or identifiers
    class PositionRequestError < StandardError; end

    # = PositionDeleteError
    # Invalid delete actions or identifiers
    class PositionDeleteError < StandardError; end
    
    attr_reader :id, :updated, :title, :feed_link, :exchange, :symbol, :shares, 
                :full_name, :gain_percentage, :return1w, :return4w, :return3m, 
                :return_ytd, :return1y, :return3y, :return5y, :return_overall, 
                :cost_basis, :days_gain, :gain, :market_value
                
    def pid
      @id.position_feed_id
    end
    
    def self.find(id, options={})   
      find_by_url("#{GF_PORTFOLIO_FEED_URL}/#{id.portfolio_id}/positions/#{id.position_id}", options)    
    end
    
    def transactions(options={})
      if options[:refresh]
        @transactions = Transaction.find(pid, options)
      else
        @transactions ||= Transaction.find(pid, options)
      end            
      
      @transactions.is_a?(Array) ? @transactions : [@transactions]      
    end

    def self.delete(id)
      delete_position(id)
    end
    
    def delete
      Position.delete(pid)
      freeze
    end
    
    def self.find_by_url(url, options = {})
      positions = []
      url += "?returns=true" if options[:returns]
      
      response = GFService.send_request(GFRequest.new(url))
      
      if response.status_code == HTTPOK
        positions = PositionFeedParser.parse_position_feed(response.body) if response.status_code == 200
      else
        raise PositionRequestError, response.body
      end

      positions.each { |p| p.instance_variable_set("@transactions", p.transactions(options))} if options[:eager]
      
      return positions[0] if positions.size == 1
      
      positions              
    end 
    
    #In order to delete a position you must delete all the transactions that fall under
    #that position.
    def self.delete_position(id)
      begin
        trans = Transaction.find("#{id.portfolio_id}/#{id.position_id}")
        if trans.class == Transaction
          trans.delete
        else
          trans.each {|t| t.delete }
        end
      rescue Transaction::TransactionRequestError => e
        raise PositionDeleteError, e.message
      rescue String::ParseError
        raise PositionDeleteError, 'Invalid Position ID'
      end
      nil
    end
    
    private_class_method :find_by_url, :delete_position
  end
end
