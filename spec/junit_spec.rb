describe Junit do
    
  describe 'defaults' do
    
    before do
      @junit = Junit.new
    end
    
    it 'has an empty list of classes by default' do
      @junit.classes.should be_empty
    end
    
  end
  
  describe '#initialize' do
    
    it 'takes a list of classes as argument' do
      @junit = Junit.new('com.example.HelloWorld', 'com.example.FooBar')
      @junit.classes.should eql(['com.example.HelloWorld', 'com.example.FooBar'])
    end
    
  end
  
end