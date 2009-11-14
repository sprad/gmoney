module GMoney
  class Position
    class PositionRequestError < StandardError; end
    class PositionDeleteError < StandardError; end
    
    attr_reader :id, :updated, :title, :feed_link, :exchange, :symbol, :shares, 
                :full_name, :gain_percentage, :return1w, :return4w, :return3m, 
                :return_ytd, :return1y, :return3y, :return5y, :return_overall, 
                :cost_basis, :days_gain, :gain, :market_value
    
    def self.find(id, options={})   
      find_by_url("#{GF_PORTFOLIO_FEED_URL}/#{id.portfolio_id}/positions/#{id.position_id}", options)    
    end
    
    def transactions(options={})
      if options[:refresh]
        @transactions = Transaction.find(@id.position_feed_id, options)
      else
        @transactions ||= Transaction.find(@id.position_feed_id, options)
      end            
      
      @transactions.is_a?(Array) ? @transactions : [@transactions]      
    end

    def self.delete(id)
      delete_position(id)
    end
    
    def delete
      Position.delete(@id.position_feed_id)
      freeze
    end
    
    def self.find_by_url(url, options = {})
      positions = []
      url += "?returns=true" if options[:returns]
      
      response = GFService.send_request(GFRequest.new(url, :headers => {"Authorization" => "GoogleLogin auth=#{GFSession.auth_token}"}))
      
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
