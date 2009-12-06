require 'tmpdir'
require 'fileutils'

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Javac do

  before do
    @output_dir = File.join(Dir.tmpdir, "javac_intg_spec_#{rand(1_000_000)}")
    @base_dir = File.dirname(__FILE__) + '/data/sources'

    @javac = Javac.new
    @javac.destination = @output_dir
    
    Dir.mkdir(@output_dir)
  end
  
  after do
    FileUtils.rm_rf(@output_dir)
  end

  context 'compile class' do
    before do
      @javac.source_files = Dir["#{@base_dir}/**/HelloWorld.java"]
      @javac.execute
    end
    
    it 'is runnable' do
      output = %x(cd #{@output_dir} && java com.example.HelloWorld)
      output.should == "Hello world\n"
    end
  end
  
  context 'compile class with syntax errors' do
    before do
      @javac.source_files = Dir["#{@base_dir}/**/Error.java"]
    end
    
    it 'prints errors' do
      io = StringIO.new

      @javac.execute(io)
      
      io.string.should include("com/example/Error.java:7")
      io.string.should include("not a statement")
    end
  end
end