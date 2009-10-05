require 'java'
require 'lib/junit-4.7.jar'

include_class 'java.lang.ClassLoader'
include_class 'java.lang.ClassNotFoundException'
include_class 'java.net.URLClassLoader'
include_class 'java.net.URL'

include_class 'org.junit.runner.JUnitCore'
include_class 'org.junit.internal.TextListener'


@urls = ['build'].map do |e|
  full_path  = File.expand_path(e)
  full_path += '/' if File.directory?(full_path) && full_path[-1] != '/'
    
  URL.new('file', 'localhost', full_path)
end

@class_loader = URLClassLoader.new(@urls.to_java(URL), ClassLoader.system_class_loader)

@classes = ['com.example.TestHelloWorld'].map do |c|
  @class_loader.load_class(c)
end

junit = JUnitCore.new
junit.add_listener(TextListener.new(java.lang.System.err));
junit.run(@classes.to_java(java.lang.Class))