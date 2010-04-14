module GMoney
  # = PositionFeedParser
  #
  # Parses Position feeds returned from the Google Finance API
  #
  class PositionFeedParser < FeedParser
    def self.parse_position_feed(position_feed)
      parse_feed(position_feed, Position, {:feed_link => true, :symbol => true})
    end
  end 
end
