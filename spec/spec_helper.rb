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
  stub_request(verb, "https://foobarapikey:x@liquidfiles.net/#{call}").to_return(fixture("#{call}_#{status}"))
end

def options
  {
    subject: "This is test email subject.",
    message: "This is test email body!",
    files: [fixture_path + "/files/test.txt"],
    recipients: ["albus@gmail.com", "severus@hotmail.com"],
    cc: [],
    bcc: [],
    attachments: nil
  }
end

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end
