require 'spec_helper'

describe LiquidFiles do
  describe "upload call" do
    it "should fail when given no files"
    it "should be made with proper content type"
    it "should authenticate using basic auth"
    it "should fail when file has prohibited extension"
    it "should fail when file has prohibited file type"
    it "should fail when file is too big"
    it "should return numeric id for each attached file"
    it "should make one call for each file uploaded"
  end
end
