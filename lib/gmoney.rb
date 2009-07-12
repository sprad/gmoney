$:.unshift File.expand_path(File.dirname(__FILE__))

require 'net/http'
require 'net/https'

require 'gmoney/authentication_request'
require 'gmoney/data_request'
require 'gmoney/portfolio'
require 'gmoney/session'

module GMoney
  VERSION = '0.1.0'
	GF_URL = "https://finance.google.com/finance/default"
  GF_FEED_URL = "#{GF_URL}/feeds"

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end
end
