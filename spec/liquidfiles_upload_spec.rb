require 'spec_helper'

describe LiquidFiles do
  describe "upload call" do
    subject {LiquidFiles::Client.new(api_key: "foobarapikey", api_url: "https://liquidfiles.net")}
    before do
      @file_tar = fixture_path + "/files/test.tar"
      @file_txt = fixture_path + "/files/test.txt"
      @file_none = fixture_path + "/files/test.none"
      stub_api_call(:post, "account",:"success")
      stub_api_call(:post, "attachments")
    end
    
    it "should fail when given no files" do
      expect { subject.upload }.to raise_error
    end

    it "should fail when file has prohibited extension" do
      expect { subject.upload([@file_tar]) }.to raise_error
    end

    it "should fail when file doesnt exits" do
      expect { subject.upload([@file_none]) }.to raise_error
    end

    context "when allowed file types are provided" do
      before do
        stub_api_call(:post, "account",:"success_filetypes")
      end

      it "should fail when file has file type different that allowed" do
        expect{ subject.upload([@file_txt]) }.to raise_error
      end

      it "should succeed when file has allowed file type" do
        expect( subject.upload([@file_tar]) ).to eq([[@file_tar,"183"]])
      end

    end

    it "should fail when file is too big" do
      File.stub(:size) { 11 * 2**20 }
      expect{ subject.upload([@file_txt]) }.to raise_error
    end

    it "should return numeric id for each attached file" do
      expect( subject.upload([@file_txt, @file_txt]).length ).to be(2)
    end
    
    it "should make one call for each file uploaded"
  end
end
