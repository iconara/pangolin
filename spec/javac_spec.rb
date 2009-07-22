describe Javac do
  
  before(:each) do
    @javac = Javac.new
  end
  
  describe " defaults" do
    
    it "should default to using 'src' as source path" do
      @javac.source_path.should == ['src']
    end
    
    it "should default to using 'build' as destination" do
      @javac.destination.should == 'build'
    end
    
    it "should have an empty source files list" do
      @javac.source_files.should be_empty
    end
    
    it "should have an empty classpath" do
      @javac.class_path.should be_empty
    end
    
    it "should compile with deprecation warnings" do
      @javac.deprecation_warnings.should be_true
    end
    
    it "should have no specified encoding" do
      @javac.encoding.should be_nil
    end
    
    it "should show warnings" do
      @javac.warnings.should be_true
    end
    
  end
    
  describe " command string" do
    
    it "should include all named source files in the command string" do
      source_files = ['Main.java', 'com/example/Something.java']
  
      @javac.source_files = source_files
  
      source_files.each do |file_name|
        @javac.command_string.should match(/Main.java com\/example\/Something\.java$/)
      end
    end

    it "should set the sourcepath to include the specified directory" do
      @javac.source_path = ['path/to/src']
  
      @javac.command_string.should include('-sourcepath path/to/src')
    end
    
    it "should set the sourcepath to include the specified directories" do
      @javac.source_path = ['path/to/src', 'another/path', 'sources']
  
      @javac.command_string.should include('-sourcepath path/to/src:another/path:sources')
    end
    
    it "should not add the sourcepath flag if source_path is empty" do
      @javac.source_path = [ ]
      
      @javac.command_string.should_not include('-sourcepath')
    end

    it "should set the destination directory to the specified directory" do
      @javac.destination = 'path/to/build'
  
      @javac.command_string.should include('-d path/to/build')
    end
  
    it "should not add the d flag if destination is nil" do
      @javac.destination = nil
      
      @javac.command_string.should_not include('-d')
    end
    
    it "should not add the d flag if destination is an empty string" do
      @javac.destination = ""
      
      @javac.command_string.should_not include('-d')
    end
    
    it "should not add the d flag if destination is only whitespace" do
      @javac.destination = "  \t"
    
      @javac.command_string.should_not include('-d')
    end
    
    it "should set the deprecation flag when deprecation_warnings is false" do
      @javac.deprecation_warnings = false
      
      @javac.command_string.should include('-deprecation')
    end
    
    it "should not set the deprecation flag when deprecation_warnings is true" do
      @javac.deprecation_warnings = true
      
      @javac.command_string.should_not include('-deprecation') 
    end
    
    it "should set the classpath to the specified directory" do
      @javac.class_path = ['path/to/classes']

      @javac.command_string.should include('-classpath path/to/classes')
    end
    
    it "should set the classpath to the specified directories and files" do
      @javac.class_path = ['path/to/classes', 'lib/dependency.jar']

      @javac.command_string.should include('-classpath path/to/classes:lib/dependency.jar')
    end
    
    it "should not set the encoding flag if encoding is nil" do
      @javac.encoding = nil
      
      @javac.command_string.should_not include('-encoding')
    end
    
    it "should set the encoding flag when encoding is set" do
      @javac.encoding = 'Shift_JIS'
      
      @javac.command_string.should include('-encoding Shift_JIS')
    end
    
    it "should set the nowarn flag when warnings is false" do
      @javac.warnings = false
      
      @javac.command_string.should include('-nowarn')
    end
    
    it "should not set the nowarn flag when warnings is true" do
      @javac.warnings = true
      
      @javac.command_string.should_not include('-nowarn')
    end

  end
  
end