require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney::PositionFeedParser do
  before(:all) do
    feed = File.read('spec/fixtures/positions_feed_for_portfolio_9.xml')
    @positions = GMoney::PositionFeedParser.parse_position_feed(feed)
    
    empty_feed = File.read('spec/fixtures/positions_feed_for_portfolio_14.xml')
    @empty_positions = GMoney::PositionFeedParser.parse_position_feed(empty_feed)
    
    feed_with_returns = File.read('spec/fixtures/positions_feed_for_portfolio_9r.xml')
    @positions_with_returns = GMoney::PositionFeedParser.parse_position_feed(feed_with_returns)
  end

  it "should create Position objects out of position feeds" do
    @positions.each do |position|
      position.should be_instance_of(GMoney::Position)
    end
  end
  
  it "should return an Array of Position objects equal to the size of Position entries" do    
    @positions.size.should be_eql(5)
  end
  
  it "should return an empty position if the user has not made any of her own" do
    @default_positions.should be_nil
  end
  
  it "should create Position objects with valid numeric data types for the returns" do
    @positions_with_returns.each do |position|
      position.public_methods(false).each do |pm|           
        if (['shares', 'gain_percentage', 'return1w', 'return4w', 'return3m', 'return_ytd', 'return1y', 'return3y', 'return5y', 'return_overall', 'cost_basis', 'days_gain', 'gain', 'market_value'].include? pm) && !(pm.include?('='))
          return_val = position.send(pm)
          return_val.should be_instance_of(Float) if return_val
        end
      end
    end
  end
end
