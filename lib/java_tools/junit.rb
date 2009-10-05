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
      
      puts "%d/%d" % [result.run_count, result.failure_count]
    end
  
  private
  
    def full_class_path
      @class_path + [File.dirname(__FILE__) + '/ext/junit-4.7.jar']
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