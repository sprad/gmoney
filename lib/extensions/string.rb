class String
  class PortfolioParseError < StandardError; end
  class PositionParseError < StandardError; end
  class TransactionParseError < StandardError; end
  
  @@portfolio_re = /\d+/
  @@portfolio_re_in = /^\d+$/  
  @@position_re = /\d+\/[a-zA-Z]+:[a-zA-Z]+/
  @@position_re_in = /^\d+\/[a-zA-Z]+:[a-zA-Z]+$/
  @@transaction_re = /\d+\/[a-zA-Z]+:[a-zA-Z]+\/\d+/
  @@transaction_re_in = /^\d+\/[a-zA-Z]+:[a-zA-Z]+\/\d+$/


  def camel_to_us
    add_us = gsub(/(.)([A-Z][a-z]+)/, '\1_\2')
    add_us.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase  
  end
  
  def is_numeric?
    Float self rescue false
  end
  
  def portfolio_feed_id
    self[self.rindex('/')+1..-1]
  end
  
  def position_feed_id
   portfolio = self[self.rindex('portfolios/')+11..index('/positions')-1]
   position = self[rindex('/')+1..-1]
   "#{portfolio}/#{position}"
  end  
  
  def portfolio_id
    if self[@@transaction_re_in] || self[@@position_re_in] || self[@@portfolio_re_in]
      self[@@portfolio_re]
    else
      raise PortfolioParseError
    end
  end
  
  def position_id
    if self[@@portfolio_re_in] 
      ""
    elsif self[@@position_re_in] 
      self[self.index('/')+1..-1]  
    elsif self[@@transaction_re_in]
      self[self.index('/')+1..self.rindex('/')-1] 
    else
      raise PositionParseError
    end
  end
  
  def transaction_id
    if self[@@position_re_in] 
      ""
    elsif self[@@transaction_re_in]
      self[self.rindex('/')+1..-1] 
    else
      raise TransactionParseError
    end
  end
end
