# = NilClass
# GMoney NilClass Extensions
class NilClass
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end
