# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe 'junit command' do
  
  before do
    @mock_junit = mock('junit')
  end
  
  it 'passes the first argument to the constructor of Junit' do
    @mock_junit.should_receive(:execute).and_return(true)
    
    Junit.should_receive(:new).with('one', 'two').and_return(@mock_junit)
    
    junit ['one', 'two']
  end
  
  it 'fails if #execute returns false' do
    @mock_junit.should_receive(:execute).and_return(false)
    
    Junit.should_receive(:new).and_return(@mock_junit)
    
    lambda { junit ['Class'] }.should raise_error
  end
  
    
end