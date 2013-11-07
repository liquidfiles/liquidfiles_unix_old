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
      @opts = options
    end
    
    it "should fail when given no files" do
      @opts[:files] = nil
      expect { subject.message @opts }.to raise_error ArgumentError, "Message must have at least one file attached"
    end


    it "should fail when no recipients given" do
      @opts[:recipients] = nil
      @opts[:cc] = nil
      @opts[:bcc] = nil
      expect { subject.message @opts }.to raise_error ArgumentError, "Message must have recipients"
    end

    it "should fail when recipients email isnt in one of allowed domains" do
      @opts[:recipients] = ["tom@marvolo.riddle"]
      expect { subject.message @opts }.to raise_error ArgumentError, "Message recipients emails can only be from allowed domains"
    end

    it "should fail when no body given" do
      @opts[:message] = nil
      expect { subject.message @opts }.to raise_error ArgumentError, "Message body can't be empty"
    end

    it "should fail when no subject given" do
      @opts[:subject] = nil
      expect { subject.message @opts }.to raise_error ArgumentError, "Message subject can't be empty"
    end

  end
end
