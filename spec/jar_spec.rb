require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe Jar do
  
  before(:each) do
    @output = 'archive.jar'
    @jar    = Jar.new(@output)
  end
  
  describe " defaults" do
    
    it "should set the output file specified in the constructor" do
      @jar.output.should == @output
    end
    
    it "should have a default compression rate between 0 and 9" do
      (@jar.compression >= 0).should be_true
      (@jar.compression <= 9).should be_true
    end
    
    it "should have a default manifest" do
      @jar.manifest_string.should_not be_nil
    end
    
    it "should have no entries" do
      @jar.entries.should be_empty
    end
    
  end
  
  describe "#initialize" do
    
    it "should take a path to the output file as parameters" do
      output = 'path/to/output.jar'
      
      jar = Jar.new(output)
      
      jar.output.should == output
    end
    
    it "should take a path to the output and a list of files as parameters" do
      output = 'output.jar'
      files  = [__FILE__]
      
      jar = Jar.new(output, files)
      
      jar.output.should == output
      jar.entries.should == [__FILE__]
    end
    
  end
  
  describe "#archive_path" do
    
    it "should remove the base dir path from the archive path" do
      @jar.find_archive_path('build/com/example/HelloWorld.class', 'build').should == 'com/example/HelloWorld.class'
    end
    
    it "should not remove anything from a file not in the base dir path" do
      @jar.find_archive_path('some/other/path', 'build').should == 'some/other/path'
    end
    
    it "should not remove anything from a file path if the base dir path is nil" do
      @jar.find_archive_path('some/other/path', nil).should == 'some/other/path'
    end
    
  end
  
  describe " manifest" do
    
    it "should include the Built-By key" do
      @jar.manifest_string.include?('Built-By').should be_true
    end
    
    it "should include added attributes" do
      @jar.manifest = {'abc' => '123'}
      
      @jar.manifest_string.include?('abc: 123').should be_true
    end
    
    it "should write the attributes on the right format" do
      @jar.manifest = {'one' => '1', 'two' => '2', 'three' => '3'}
      
      @jar.manifest_string.include?("one: 1\n").should be_true
      @jar.manifest_string.include?("two: 2\n").should be_true
      @jar.manifest_string.include?("three: 3\n").should be_true
    end
        
    it "should not begin with whitespace" do
      @jar.manifest_string[0..1].should_not match(/\s/)
    end
    
    it "should reject an empty attribute name" do
      lambda {
        @jar.manifest = {'' => '432'}
      }.should raise_error(ArgumentError)
    end

    it "should reject nil as attribute name" do
      lambda {
        @jar.manifest = {nil => 'Hello world'}
      }.should raise_error(ArgumentError)
    end
    
    it "should reject an attribute name containing a space" do
      lambda {
        @jar.manifest = {'Hello World' => 'foo'}
      }.should raise_error(ArgumentError)
    end
    
    it "should reject an attribute name containing a colon" do
      lambda {
        @jar.manifest = {'Hello:World' => 'foo'}
      }.should raise_error(ArgumentError)
    end
    
    it "should accept a variety of legal attribute names" do
      lambda {
        @jar.manifest = {
          'Manifest-Version' => 'foo',
          'Created-By' => 'foo',
          'Signature-Version' => 'foo',
          'Class-Path' => 'foo'
        }
      }.should_not raise_error
    end
    
    it "should ignore case when setting attributes" do
      @jar.manifest = {'Hello' => 'World', 'hello' => 'Theo'}
      
      @jar.manifest_string.include?('Hello: World').should be_false
      @jar.manifest_string.include?('hello: Theo').should be_true
    end
        
  end
  
  describe "#main_class=" do
    
    it "should set the Main-Class attribute" do
      @jar.main_class = 'com.example.Main'
      
      @jar.manifest_string.include?('Main-Class: com.example.Main').should be_true
    end
    
  end

  describe "#add_file" do
    
    it "should add an entry" do
      path = __FILE__
      
      @jar.add_file(path)
      
      @jar.entries.include?(path).should be_true
    end
    
    it "should add an entry at the specified archive path" do
      path = __FILE__
      archive_path = 'some/other/path.rb'
      
      @jar.add_file(path, archive_path)
      
      @jar.entries.include?(path).should be_false
      @jar.entries.include?(archive_path).should be_true
    end
    
    it "should raise an exception if the file doesn't exist" do
      lambda {
        @jar.add_file('some/bogus/path')
      }.should raise_error(ArgumentError)
    end
    
    it "should raise an exception if the argument is a directory" do
      lambda {
        @jar.add_file(File.dirname(__FILE__))
      }.should raise_error(ArgumentError)
    end
            
  end
  
  describe "#add_blob" do
    
    it "should add an entry" do
      archive_path = 'some/path/to/a/file.txt'
      
      @jar.add_blob('one two three', archive_path)
      
      @jar.entries.include?(archive_path).should be_true
    end
            
  end
  
  describe "#add_files" do
    
    it "should add all files" do
      files = Dir.glob(File.dirname(__FILE__) + '/*.rb')
      
      @jar.add_files(files)
      
      files.each do |file|
        @jar.entries.include?(file).should be_true
      end
    end
    
    it "should remove the base dir from all file paths" do
      files = Dir.glob(File.dirname(__FILE__) + '/*.rb').map { |f| File.expand_path(f) }
      base_dir = File.expand_path(File.dirname(__FILE__ + '/..'))
      
      @jar.add_files(files, base_dir)
      
      files.each do |file|
        @jar.entries.include?(file.gsub(base_dir + '/', '')).should be_true
      end
    end
    
    it "should raise an exception if any of the files is a directory" do
      files = [__FILE__, File.dirname(__FILE__)]
      
      lambda {
        @jar.add_files(files)
      }.should raise_error(ArgumentError)
    end
    
    it "should raise an exception if any file doesn't exist" do
      files = [__FILE__, 'some/bogus/path.txt']
      
      lambda {
        @jar.add_files(files)
      }.should raise_error(ArgumentError)
    end
    
  end
  
  describe "#remove_entry" do
    
    it "should remove an added file" do
      @jar.add_file(__FILE__)
      @jar.remove_entry(__FILE__)

      @jar.entries.include?(__FILE__).should be_false
    end
    
    it "should remove an added blob" do
      @jar.add_blob('foobar', 'foo/bar')
      @jar.remove_entry('foo/bar')
      
      @jar.entries.include?('foo/bar').should be_false
    end
    
    it "should not do anything when removing an entry that does not exist" do
      lambda {
        @jar.remove_entry('non/existent/entry')
      }.should_not change(@jar, :entries)
    end
    
  end
  
end