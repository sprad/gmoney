class String
	def camel_to_us
		add_us = gsub(/(.)([A-Z][a-z]+)/, '\1_\2')
		add_us.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase	
	end
	
	def is_numeric?
		Float self rescue false
	end
end
