#figure out what this does
$:.unshift File.expand_path(File.dirname(__FILE__))

require 'net/http'
require 'net/https'

require 'extensions/string'

require 'gmoney/authentication_request'
require 'gmoney/gf_portfolio_feed_parser'
require 'gmoney/gf_request'
require 'gmoney/gf_response'
require 'gmoney/gf_service'
require 'gmoney/portfolio'
require 'gmoney/session'

#TODO - Is it common practice to have your code wrapped in a module like "GMoney" to create a namespace?
#ask garb guys at the next ruby hack night
module GMoney
  VERSION = '0.1.0'
	GF_URL = "https://finance.google.com/finance"
  GF_FEED_URL = "#{GF_URL}/feeds/default"

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end
end
