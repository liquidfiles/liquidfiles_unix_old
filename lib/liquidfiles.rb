require 'yaml'
require 'curb'
require "net/http"
require "uri"
require 'nokogiri'
require "liquidfiles/version"
require "liquidfiles/client"

module LiquidFiles
  def self.version_string
    "LiquidFiles version #{LiquidFiles::VERSION}"
  end
end
