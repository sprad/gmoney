require File.join(File.dirname(__FILE__), '/spec_helper')

describe GMoney do

  it "should not have a nil VERSION number" do
    GMoney.version.should_not be_nil
  end

end
