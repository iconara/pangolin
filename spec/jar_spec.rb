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
  
  describe "#archive_path" do
    
    it "should remove the base dir path from the archive path" do
      @jar.base_dir = 'build'

      @jar.archive_path('build/com/example/HelloWorld.class').should == 'com/example/HelloWorld.class'
    end
    
    it "should not remove anything from a file not in the base dir path" do
      @jar.base_dir = 'build'
      
      @jar.archive_path('some/other/path').should == 'some/other/path'
    end
    
    it "should not remove anything from a file path if the base dir path is nil" do
      @jar.base_dir = nil
      
      @jar.archive_path('some/other/path').should == 'some/other/path'
    end
    
  end
  
  describe "#manifest/#add_manifest_attribute" do
    
    it "should include the Built-By key" do
      @jar.manifest.include?('Built-By').should be_true
    end
    
    it "should include added attributes" do
      @jar.add_manifest_attribute('abc', '123')
      
      @jar.manifest.include?('abc: 123').should be_true
    end
    
    it "should write the attributes on the right format" do
      @jar.add_manifest_attribute('one', '1')
      @jar.add_manifest_attribute('two', '2')
      @jar.add_manifest_attribute('three', '3')
      
      @jar.manifest.include?("one: 1\n").should be_true
      @jar.manifest.include?("two: 2\n").should be_true
      @jar.manifest.include?("three: 3\n").should be_true
    end
    
    it "should only use the last set value of an attribute" do
      @jar.add_manifest_attribute('one', '2')
      @jar.add_manifest_attribute('one', '1')
      
      @jar.manifest.include?('one: 2').should_not be_true
      @jar.manifest.include?('one: 1').should be_true
    end
    
    it "should reject an empty attribute name" do
      lambda {
        @jar.add_manifest_attribute('', '432')
      }.should raise_error(ArgumentError)
    end

    it "should reject nil as attribute name" do
      lambda {
        @jar.add_manifest_attribute(nil, 'Hello world')
      }.should raise_error(ArgumentError)
    end
    
    it "should reject an attribute name containing a space" do
      lambda {
        @jar.add_manifest_attribute('Hello World', 'foo')
      }.should raise_error(ArgumentError)
    end
    
    it "should reject an attribute name containing a colon" do
      lambda {
        @jar.add_manifest_attribute('Hello:World', 'foo')
      }.should raise_error(ArgumentError)
    end
    
    it "should accept a variety of legal attribute names" do
      lambda {
        @jar.add_manifest_attribute('Manifest-Version', 'foo')
        @jar.add_manifest_attribute('Created-By', 'foo')
        @jar.add_manifest_attribute('Signature-Version', 'foo')
        @jar.add_manifest_attribute('Class-Path', 'foo')
      }.should_not raise_error
    end
        
  end
  
end