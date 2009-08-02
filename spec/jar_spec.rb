require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe Jar do
  
  before(:each) do
    @jar = Jar.new
  end
  
  describe " defaults" do
    
    it "should set output to nil" do
      @jar.output.should be_nil
    end
    
    it "should set basedir to the current directory" do
      @jar.base_dir.should == '.'
    end
    
    it "should have a default compression rate between 0 and 9" do
      (@jar.compression >= 0).should be_true
      (@jar.compression <= 9).should be_true
    end
    
    it "should have a default manifest" do
      @jar.manifest.should_not be_nil
    end
    
    it "should have an empty list of files" do
      @jar.files.should be_empty
    end
    
  end
  
  describe "#initialize" do
    
    it "should take the list of files as an argument to the constructor" do
      f1 = 'one/two/three.java'
      f2 = 'four/five/six.java'
      
      jar = Jar.new(f1, f2)
      
      jar.files.include?(f1).should be_true
      jar.files.include?(f2).should be_true
    end
    
  end
  
end