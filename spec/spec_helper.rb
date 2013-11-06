require 'rspec'
require 'webmock/rspec'
require 'liquidfiles'

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def stub_api_call(verb, call, status=:success)
  stub_request(verb, "https://foobarapikey:x@green.liquidfiles.net/#{call}").to_return(fixture("#{call}_#{status}"))
end

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end
