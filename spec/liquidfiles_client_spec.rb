require 'spec_helper'

describe LiquidFiles::Client do
  describe "#new" do
    
    context "when correct api key is used" do 
      subject {LiquidFiles::Client.new("foobarapikey")}
   
      before do
        stub_api_call(:post, "account")
      end
    
      it 'should populate client settings' do
        expect( subject.settings ).not_to be_nil
        expect( subject.settings ).not_to be_empty
        expect( subject.settings[:api_version] ).to eq("3")
        expect( subject.settings[:change_expiration] ).to be(true)
      end
    end

    context "when incorrect api key is used" do
   
      before do
        stub_api_call(:post, "account", :failure)
      end

      it "should throw exception" do
        expect { LiquidFiles::Client.new("foobarapikey") }.to raise_error LiquidFiles::ApiError
      end
    end
  end
end