class String
	#TODO Might be able to improve performance by pre-compiling regex?  Is this possible in Ruby?
	#http://stackoverflow.com/questions/1175208/does-the-python-standard-library-have-function-to-convert-camelcase-to-camelcase
	def camel_to_us
		self.gsub!(/(.)([A-Z][a-z]+)/, '\1_\2')
		self.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase	
	end
end
