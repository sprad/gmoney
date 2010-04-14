# = String
# GMoney String Extensions
class String
  # = ParseError
  # Incorrect id/url parsing
  class ParseError < StandardError; end

  # = PortfolioParseError
  # Incorrect portfolio id/url parsing
  class PortfolioParseError < ParseError; end

  # = PositionParseError
  # Incorrect position id/url parsing
  class PositionParseError < ParseError; end

  # = TransactionParseError
  # Incorrect transaction id/url parsing
  class TransactionParseError < ParseError; end
  
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
   portfolio = finance_feed_id_helper('portfolios', 11)
   position = self[rindex('/')+1..-1]
   "#{portfolio}/#{position}"
  end  
  
  def transaction_feed_id
   portfolio = finance_feed_id_helper('portfolios', 11)
   position = finance_feed_id_helper('positions', 10)
   transaction = self[rindex('/')+1..-1]
   "#{portfolio}/#{position}/#{transaction}"
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
  
  def blank?
    respond_to?(:empty?) ? self.strip.empty? : !self
  end
  
  private
  
  def finance_feed_id_helper(finance_object, offset)
    f_objs = finance_object == 'portfolios' ? ['portfolios/', '/positions'] : ['positions/', '/transactions']
    self[self.rindex(f_objs[0])+offset..index(f_objs[1])-1]
  end
end
