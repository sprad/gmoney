# Justin Spradlin
# www.fiascode.com
# (C) 2009


$:.unshift File.expand_path(File.dirname(__FILE__))

require 'date'
require 'net/http'
require 'net/https'
require 'rexml/document'

require 'extensions/fixnum'
require 'extensions/nil_class'
require 'extensions/string'

require 'gmoney/authentication_request'
require 'gmoney/feed_parser.rb'
require 'gmoney/gf_request'
require 'gmoney/gf_response'
require 'gmoney/gf_service'
require 'gmoney/gf_session'
require 'gmoney/portfolio'
require 'gmoney/portfolio_feed_parser'
require 'gmoney/position'
require 'gmoney/position_feed_parser'
require 'gmoney/transaction'
require 'gmoney/transaction_feed_parser'

module GMoney
  VERSION = '0.2.1'
  GF_URL = "https://finance.google.com/finance"
  GF_FEED_URL = "#{GF_URL}/feeds/default"
  GF_PORTFOLIO_FEED_URL = "#{GF_FEED_URL}/portfolios"
  
  HTTPOK = 200
  HTTPCreated = 201
  
  def self.version
    VERSION
  end
end
