# Justin Spradlin
# www.justinspradlin.com
# (C) 2010


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
  VERSION = '0.4.3'
  GF_URL = "http://finance.google.com/finance"
  GF_FEED_URL = "#{GF_URL}/feeds/default"
  GF_PORTFOLIO_FEED_URL = "#{GF_FEED_URL}/portfolios"
  GF_GOOGLE_DATA_VERSION = 2
  
  HTTPOK = 200
  HTTPCreated = 201
  
  BUY = 'Buy'
  SELL = 'Sell'
  SELL_SHORT = 'Sell Short'
  BUY_TO_COVER = 'Buy to Cover'  
  
  def self.version
    VERSION
  end
end
