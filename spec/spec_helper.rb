require File.dirname(__FILE__) + '/../lib/gmoney'

def get_feed_ids(feed)
  doc = REXML::Document.new(feed)
  feed_ids = []     

  doc.elements.each('//entry') do |parsed_entry|
    feed_ids << parsed_entry.elements['id'].text
  end
  feed_ids
end
