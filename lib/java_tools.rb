raise "JavaTools requires JRuby" unless RUBY_PLATFORM =~ /\bjava\b/


require File.expand_path(File.dirname(__FILE__)) + '/java_tools/javac'
require File.expand_path(File.dirname(__FILE__)) + '/java_tools/jar'


def javac( source_files, options = nil )
  obj = JavaTools::Javac.new(*source_files)
  
  if block_given?
    yield obj
  elsif options
    options.each do |option, value|
      setter_name = "#{option}="
      
      if obj.respond_to? setter_name
        obj.send(setter_name, value)
      else
        raise ArgumentError, "Invalid option: #{option}"
      end
    end
  end
  
  obj.execute
end

def jar( output )
  obj = JavaTools::Jar.new(output)
  
  yield obj if block_given?
  
  obj.execute
end