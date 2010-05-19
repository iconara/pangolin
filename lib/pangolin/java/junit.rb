# encoding: utf-8

require 'java'


ClassLoader = java.lang.ClassLoader
ClassNotFoundException = java.lang.ClassNotFoundException
URLClassLoader = java.net.URLClassLoader
JURL = java.net.URL


module Pangolin

  class Junit
    
    include JunitCommon
    
    require JUNIT_JAR_PATH
      
    def execute(io=$stderr)
      raise 'No tests' if @class_names.nil? || @class_names.empty?
      
      io.puts 'junit …' if @verbose
      
      junit  = load_class('org.junit.runner.JUnitCore').new_instance
      result = junit.run(class_instances)
      
      print_result(io, result)
      
      0 == result.failure_count
    end
      
  private
  
    def print_result(io, result)
      print_header(io, result.run_count, result.failure_count, result.run_time)
      
      unless result.was_successful
        result.failures.each do |failure|
          print_failure(io, failure.test_header, failure.message, failure.trace)
        end
      end
    end

    def full_class_path
      @class_path + [JUNIT_JAR_PATH]
    end
  
    def pretty_class_path
      full_class_path.join(':')
    end

    def class_path_urls
      full_class_path.map do |e|
        full_path  = File.expand_path(e)
        full_path += '/' if File.directory?(full_path) && full_path[-1] != '/'
        
        JURL.new('file', 'localhost', full_path)
      end
    end

    def class_loader
      @class_loader ||= URLClassLoader.new(class_path_urls.to_a.to_java(JURL), ClassLoader.system_class_loader)
    end

    def class_instances
      @class_names.map { |class_name| load_class(class_name) }.to_a.to_java(java.lang.Class)
    end
    
    def load_class(class_name)
      class_loader.load_class(class_name)
    rescue ClassNotFoundException => e
      raise LoadError, "Class not found: #{class_name} (looking in #{pretty_class_path})"
    end
  
  end
  
end