describe "javac command" do
  
  it "should pass the first argument to the constructor of Javac" do
    files = ['one/two.java', 'three/four.java']
    
    instance = Javac.new(*files)
    instance.should_receive(:execute).and_return(true) # stop the real execute from being called
    
    Javac.should_receive(:new).with(*files).and_return(instance)
    
    javac files
  end
  
  it "should yield a Javac object if a block is given" do
    # prepare a stub that prevents the real #execute being called
    instance = Javac.new
    instance.should_receive(:execute).and_return(true)
    
    Javac.should_receive(:new).and_return(instance)
    
    javac('Main.java') do |conf|
      conf.should be_instance_of(Javac)
    end
  end
  
  it "should set properties on the yielded Javac instance" do
    destination = 'build'
    source_path = ['xyz', 'abc']
    
    instance = Javac.new('Main.java')
    
    Javac.should_receive(:new).and_return do
      instance.should_receive(:destination=).with(destination)
      instance.should_receive(:source_path=).with(source_path)
      instance.should_receive(:execute).and_return(true) # stop the real execute from being called
      instance
    end
    
    javac('Main.java') do |conf|
      conf.destination = destination
      conf.source_path = source_path
    end
  end
  
  it "should call #execute after yielding" do
    Javac.should_receive(:new).and_return do
      instance = mock('JavacInstance')
      instance.should_receive(:execute).and_return(true)
      instance
    end
    
    javac('Main.java') { }
  end
  
  it "should call #execute in non-yield mode" do
    files = ['one/two.java', 'three/four.java']
    
    instance = Javac.new(*files)
    
    Javac.should_receive(:new).with(*files).and_return do
      instance.should_receive(:execute).and_return(true)
      instance
    end
    
    javac files, :destination => 'build'
  end
  
  it "should fail if #execute returns false" do
    instance = mock('Javac')
    instance.should_receive(:execute).and_return(false)
    
    Javac.should_receive(:new).and_return(instance)
    
    lambda { javac ['Hello', 'World'] }.should raise_error
  end
  
  it "should set the properties specified in the options parameter" do
    files       = ['one/two.java', 'three/four.java']
    destination = 'build'
    source_path = ['src', 'common/src']
    
    instance = mock('JavacInstance')
    
    Javac.should_receive(:new).with(*files).and_return do
      instance.should_receive(:destination=).with(destination)
      instance.should_receive(:source_path=).with(source_path)
      instance.should_receive(:warnings=).with(false)
      instance.should_receive(:execute).and_return(true) # stop the real execute from being called
      instance
    end
    
    javac files, :destination => destination, :source_path => source_path, :warnings => false
  end
  
  it "should raise an exception for an invalid option" do
    lambda {
      javac ['Main.java'], :bogus => 'option'
    }.should raise_error(ArgumentError)
  end
  
end