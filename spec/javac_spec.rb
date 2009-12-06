require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe Javac do
  
  before(:each) do
    @javac = Javac.new
  end
  
  describe " defaults" do
    
    it "should default to an empty array as source path" do
      @javac.source_path.should be_empty
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
  
  describe '#initialize' do
    
    it "should take the source files as arguments to the constructor" do
      f1 = 'one/two/three.java'
      f2 = 'four/five/six.java'
      
      javac = Javac.new(f1, f2)
      
      javac.source_files.include?(f1).should be_true
      javac.source_files.include?(f2).should be_true
    end
    
  end
    
  describe '#command_args' do
    
    it "should include all named source files in the command args" do
      source_files = ['Main.java', 'com/example/Something.java']
  
      @javac.source_files = source_files
  
      source_files.each do |file_name|
        @javac.command_args.include?(file_name)
      end
    end

    it "should set the sourcepath to include the specified directory, when specified as a one item array" do
      @javac.source_path = ['path/to/src']
  
      @javac.command_args.join(' ').should include('-sourcepath path/to/src')
    end
    
    it "should set the sourcepath to include the specified directory, when specified as a string" do
      @javac.source_path = 'path/to/src'
  
      @javac.command_args.join(' ').should include('-sourcepath path/to/src')
    end
    
    it "should set the sourcepath to include the specified directories" do
      @javac.source_path = ['path/to/src', 'another/path', 'sources']
  
      @javac.command_args.join(' ').should include('-sourcepath path/to/src:another/path:sources')
    end
    
    it "should not add the sourcepath flag if source_path is empty" do
      @javac.source_path = [ ]
      
      @javac.command_args.should_not include('-sourcepath')
    end

    it "should set the destination directory to the specified directory" do
      @javac.destination = 'path/to/build'
  
      @javac.command_args.join(' ').should include('-d path/to/build')
    end
  
    it "should not add the d flag if destination is nil" do
      @javac.destination = nil
      
      @javac.command_args.join(' ').should_not match(/-d\b/)
    end
    
    it "should not add the d flag if destination is an empty string" do
      @javac.destination = ""
      
      @javac.command_args.join(' ').should_not match(/-d\b/)
    end
    
    it "should not add the d flag if destination is only whitespace" do
      @javac.destination = "  \t"
    
      @javac.command_args.join(' ').should_not match(/-d\b/)
    end
    
    it "should set the deprecation flag when deprecation_warnings is true" do
      @javac.deprecation_warnings = true
      
      @javac.command_args.should include('-deprecation')
    end
    
    it "should not set the deprecation flag when deprecation_warnings is false" do
      @javac.deprecation_warnings = false
      
      @javac.command_args.should_not include('-deprecation') 
    end
    
    it "should set the classpath to the specified directory, when specified as a one item array" do
      @javac.class_path = ['path/to/classes']

      @javac.command_args.join(' ').should include('-classpath path/to/classes')
    end
    
    it "should set the classpath to the specified directory, when specified as a string" do
      @javac.class_path = 'path/to/classes'

      @javac.command_args.join(' ').should include('-classpath path/to/classes')
    end
    
    it "should set the classpath to the specified directories and files" do
      @javac.class_path = ['path/to/classes', 'lib/dependency.jar']

      @javac.command_args.join(' ').should include('-classpath path/to/classes:lib/dependency.jar')
    end
    
    it "should not set the encoding flag if encoding is nil" do
      @javac.encoding = nil
      
      @javac.command_args.should_not include('-encoding')
    end
    
    it "should set the encoding flag when encoding is set" do
      @javac.encoding = 'Shift_JIS'
      
      @javac.command_args.join(' ').should include('-encoding Shift_JIS')
    end
    
    it "should set the nowarn flag when warnings is false" do
      @javac.warnings = false
      
      @javac.command_args.should include('-nowarn')
    end
    
    it "should not set the nowarn flag when warnings is true" do
      @javac.warnings = true
      
      @javac.command_args.should_not include('-nowarn')
    end
    
    it 'should set -Xlint:abc for all values in the lint options' do
      @javac.lint << 'empty'
      @javac.lint << '-cast'
      @javac.lint << 'divzero'
      
      @javac.command_args.should include('-Xlint:empty')
      @javac.command_args.should include('-Xlint:-cast')
      @javac.command_args.should include('-Xlint:divzero')
    end
    
    it 'should not set any -Xlint:abc flags when the lint option is empty' do
      @javac.command_args.join(' ').should_not include('-Xlint')
    end
    
    it 'should set -Xmaxerrs when the max_errors option is set' do
      @javac.max_errors = 10
      
      @javac.command_args.join(' ').should include('-Xmaxerrs 10')
    end
    
    it 'should not -Xmaxerrs when the max_errors option is not set' do
      @javac.command_args.should_not include('-Xmaxerrs')
    end
    
    it 'should set -Xmaxwarns when the max_warnings option is set' do
      @javac.max_warnings = 5
      
      @javac.command_args.join(' ').should include('-Xmaxwarns 5')
    end
    
    it 'should not -Xmaxerrs when the max_errors option is not set' do
      @javac.command_args.should_not include('-Xmaxwarns')
    end

  end
 
  describe '#execute' do
    before do
      @javac.stub!(:execute_compiler).and_return(1)
    end
    
    it 'raises an exception if there are no source files' do
      @javac.source_files = [ ]

      lambda { @javac.execute }.should raise_error
      
      @javac.source_files = nil
      
      lambda { @javac.execute }.should raise_error
    end
  end
  
end