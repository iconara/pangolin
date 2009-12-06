require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Junit do

  before do
    @junit = Junit.new('com.example.TestHelloWorld')
    @junit.class_path = [File.dirname(__FILE__) + '/data/tests']
  end
  
  it 'runs the tests' do
    io = StringIO.new
    
    @junit.execute(io)
    
    io.string.should include('2 tests run')
    io.string.should include('1 failure')
  end

end