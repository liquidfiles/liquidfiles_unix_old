require 'spec_helper'

describe LiquidFiles do
  describe "message call" do
    subject {LiquidFiles::Client.new("foobarapikey")}

    before do
      @file_tar = fixture_path + "/files/test.tar"
      @file_txt = fixture_path + "/files/test.txt"
      stub_api_call(:post, "account",:"success")
      stub_api_call(:post, "attachments")
      stub_api_call(:post, "message")
    end
    
    it "should fail when given no files" do
      opts = options
      opts[:files] = nil
      expect { subject.message opts }.to raise_error ArgumentError
    end


    it "should fail when no recipients given"
    it "should fail when recipients email isnt allowed in domain"

    it "should fail when no body given"
    it "should fail when no subject given"

  end
end
