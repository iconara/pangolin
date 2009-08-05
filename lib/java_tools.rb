raise "JavaTools requires JRuby" unless RUBY_PLATFORM =~ /\bjava\b/


require File.expand_path(File.dirname(__FILE__)) + '/java_tools/javac'
require File.expand_path(File.dirname(__FILE__)) + '/java_tools/jar'


module JavaTools

  def self.configure_command( command, options )
    options.each do |option, value|
      setter_name = "#{option}="
      
      if command.respond_to? setter_name
        command.send(setter_name, value)
      else
        raise ArgumentError, "Invalid option: #{option}"
      end
    end
  end
  
end

def javac( source_files, options = nil )
  obj = JavaTools::Javac.new(*source_files)
  
  if block_given?
    yield obj
  elsif options
    JavaTools::configure_command(obj, options)
  end
  
  obj.execute
end

def jar( output, files = nil, options = nil )
  base_dir = nil
  
  if options && options[:base_dir]
    base_dir = options[:base_dir]
  end
  
  obj = JavaTools::Jar.new(output, files, base_dir)
  
  if block_given?
    yield obj
  elsif options
    JavaTools::configure_command(obj, options)
  end
  
  obj.execute
end