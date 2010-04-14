# = Fixnum 
# GMoney Fixnum Extensions
class Fixnum
  def portfolio_id
    self.to_s.portfolio_id
  end
  
  def position_id
    self.to_s.position_id
  end
  
  def transaction_id
    self.to_s.transaction_id
  end    
end
