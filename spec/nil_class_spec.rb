require File.join(File.dirname(__FILE__), '/spec_helper')

describe NilClass do 
  it "should return true for a method call to blank?" do  
    nil.blank?.should be_true
  end
end
