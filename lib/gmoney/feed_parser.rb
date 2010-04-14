module GMoney
  # = FeedParser
  #
  # Parses Atom feeds that are returned from the Google Finance API
  # and converts its data into Ruby objects.
  #
  class FeedParser
    def self.parse_feed(feed, feed_class, options = {:feed_link => true, :symbol => false})
      doc = REXML::Document.new(feed)
      finance_objects = []      
      feed_class_string = feed_class.to_s.gsub("GMoney::", "").downcase
      
      set_ivar = lambda do |target, name, value|
        value = value.to_f if value.is_numeric?
        target.instance_variable_set("@#{name.camel_to_us}", value)
      end

      doc.elements.each('//entry') do |parsed_entry|
        finance_object = feed_class.new
        finance_data = parsed_entry.elements["gf:#{feed_class_string}Data"]

        finance_object.instance_variable_set("@id", parsed_entry.elements['id'].text)
        finance_object.instance_variable_set("@title", parsed_entry.elements['title'].text)
        finance_object.instance_variable_set("@updated", DateTime.parse(parsed_entry.elements['updated'].text))
        finance_object.instance_variable_set("@feed_link", parsed_entry.elements['gd:feedLink'].attributes['href']) if options[:feed_link]
        
        finance_data.attributes.each { |attr_name, attr_value| set_ivar.call(finance_object, attr_name, attr_value) }
        parsed_entry.elements['gf:symbol'].each { |attr_name, attr_value| set_ivar.call(finance_object, attr_name, attr_value)} if options[:symbol]

        finance_data.elements.each do |cg|
          finance_object.instance_variable_set("@#{cg.name.camel_to_us}", cg.elements['gd:money'].attributes['amount'].to_f)
        end
        finance_objects << finance_object 
      end
      finance_objects
    end
  end
end
