JUNIT_JAR_PATH = File.dirname(__FILE__) + '/ext/junit.jar'


require JUNIT_JAR_PATH


include_class 'java.lang.ClassLoader'
include_class 'java.lang.ClassNotFoundException'
include_class 'java.net.URLClassLoader'
include_class 'java.net.URL'


module JavaTools

  class Junit
    
    attr_accessor :class_path
    

    def initialize(*classes)
      @class_names = classes || [ ]
      @class_path  = [ ]
    end
  
    def classes
      @class_names
    end
  
    def execute
      junit  = load_class('org.junit.runner.JUnitCore').new_instance
      result = junit.run(class_instances)
      
      print_result(result)
    end
      
  private
  
    def print_result(result)
      if result.was_successful
        puts '%d tests run in %.1f seconds, no failures' % [result.run_count, result.run_time/1000]
      else
        args = [
          result.run_count, 
          result.run_time/1000, 
          result.failure_count, 
          result.failure_count == 1 ? '' : 's'
        ]
    
        puts '%d tests run in %.1f seconds with %d failure%s:' % args
        puts ''
      
        result.failures.each do |failure|
          puts '- %s' % [failure.test_header]
          puts '  %s' % [failure.message]
          puts '  %s' % [trace_without_library_frames(failure.trace)]
        end
      end
    end
    
    def trace_without_library_frames(trace)
      trace.split("\n").reject do |line|
        case line
        when /java.lang.AssertionError/, /at org.junit/, /at sun.reflect/, /at java.lang.reflect/, /at org.jruby/, /jrake/
          true
        else
          false
        end
      end.join("\n")
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
        
        URL.new('file', 'localhost', full_path)
      end
    end

    def class_loader
      @class_loader ||= URLClassLoader.new(class_path_urls.to_java(URL), ClassLoader.system_class_loader)
    end

    def class_instances
      @class_names.map { |class_name| load_class(class_name) }.to_java(java.lang.Class)
    end
    
    def load_class(class_name)
      class_loader.load_class(class_name)
    rescue ClassNotFoundException => e
      raise LoadError, "Class not found: #{class_name} (looking in #{pretty_class_path})"
    end
  
  end
  
end