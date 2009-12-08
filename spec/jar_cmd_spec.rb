# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe "jar command" do
  
  it "should pass the first argument to the constructor of Jar" do
    output = 'archive.jar'
    
    instance = create_non_exec_jar(output)
    
    Jar.should_receive(:new).with(output, nil, nil).and_return(instance)
    
    jar output
  end
  
  it "should pass the first and second arguments to the constructor of Jar" do
    output = 'archive.jar'
    files  = ['one/two.class', 'three/four.txt']
    
    Jar.should_receive(:new).with(output, files, nil).and_return do
      instance = mock('JarInstance')
      instance.should_receive(:execute).and_return(true)
      instance
    end
    
    jar output, files
  end
  
  it "should yield a Jar object if a block is given" do
    instance = create_non_exec_jar('archive.jar')
    
    Jar.should_receive(:new).and_return(instance)
    
    jar('archive.jar') do |conf|
      conf.should be_instance_of(Jar)
    end
  end
  
  it "should set properties on the yielded Jar instance" do
    base_dir    = 'build'
    compression = 3
    
    instance = create_non_exec_jar('archive.jar')
    
    Jar.should_receive(:new).and_return do
      instance.should_receive(:base_dir=).with(base_dir)
      instance.should_receive(:compression=).with(compression)
      instance
    end
    
    jar('archive.jar') do |conf|
      conf.base_dir    = base_dir
      conf.compression = compression
    end
  end
  
  it "should call #execute after yielding" do
    Jar.should_receive(:new).and_return do
      instance = mock('JarInstance')
      instance.should_receive(:execute).and_return(true)
      instance
    end
    
    jar('archive.jar') { }
  end
  
  it "should call #execute in non-yield mode" do
    instance = create_non_exec_jar('archive.jar')
    
    Jar.should_receive(:new).and_return(instance)
    
    jar 'archive.jar', :compression => 4
  end
  
  it "should fail if #execute returns false" do
    instance = mock('Jar')
    instance.should_receive(:execute).and_return(false)
    
    Jar.should_receive(:new).and_return(instance)
    
    lambda { jar 'archive.jar' }.should raise_error
  end
  
  it "should set the properties specified in the options parameter" do
    base_dir    = 'build'
    compression = 4
    
    Jar.should_receive(:new).and_return do
      instance = mock('JarInstance')
      instance.should_receive(:base_dir=).with(base_dir)
      instance.should_receive(:compression=).with(compression)
      instance.should_receive(:verbose=).with(false)
      instance.should_receive(:execute).and_return(true)
      instance
    end
    
    jar 'archive.jar', ['build/two/three.class'], :base_dir => base_dir, :compression => compression, :verbose => false
  end
  
  it "should raise an exception for an invalid option" do
    lambda {
      jar 'archive.jar', ['Main.class'], :bogus => 'option'
    }.should raise_error(ArgumentError)
  end
  
  it "should pass the base_dir option straight to the constructor" do
    output   = 'output.jar'
    files    = [__FILE__]
    base_dir = File.dirname(__FILE__)
    
    instance = create_non_exec_jar(output, files)
    
    Jar.should_receive(:new).with(output, files, base_dir).and_return(instance)
    
    jar output, files, :base_dir => base_dir
  end
  
  def create_non_exec_jar( output, files = nil )
    instance = Jar.new(output, files)
    instance.should_receive(:execute).and_return(true) # stop the real #execute from being called    
    instance
  end
  
end