# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


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
  
  describe '#execute' do
    it 'raises an exception if there are no tests to run' do
      lambda { @junit.execute }.should raise_error
    end
  end
  
end