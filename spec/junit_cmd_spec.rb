describe 'junit command' do
  
  before do
    @mock_junit = mock('junit')
    @mock_junit.should_receive(:execute)
  end
  
  it 'passes the first argument to the constructor of Junit' do
    Junit.should_receive(:new).with('one', 'two').and_return(@mock_junit)
    
    junit ['one', 'two']
  end
    
end