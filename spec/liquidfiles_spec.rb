require 'spec_helper'

describe LiquidFiles do
  it 'should return correct version string' do
    LiquidFiles.version_string.should == "LiquidFiles version #{LiquidFiles::VERSION}"
  end
end
