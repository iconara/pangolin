raise "JavaTools requires JRuby" unless RUBY_PLATFORM =~ /\bjava\b/


require File.expand_path(File.dirname(__FILE__)) + '/java_tools/javac'
require File.expand_path(File.dirname(__FILE__)) + '/java_tools/jar'


module JavaTools # :nodoc:
  
  def self.version # :nodoc:
    version_file = File.join(File.dirname(__FILE__), '..', 'VERSION')
    
    File.open(version_file) do |f|
      f.readline.strip
    end
  end

  def self.configure_command( command, options ) # :nodoc:
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

# Javac can be run in either command or yield mode: command mode
# looks roughly like this:
#
#   javac [file1, file2], :destination => 'build'
#
# and yield mode like this:
#
#   javac(file1, file2) do |conf|
#     conf.destination = 'build'
#   end
#
# In command mode you pass a hash with the configuration directives
# (listed below) and in yield mode an object is passed to the block,
# and the configuration directives should be set on that.
#
# The possible configuration directives are:
# * source_path
# * destination
# * class_path
# * deprecation_warnings
# * warnings
# * encoding
# * verbose
#
# The directives are the same as the properties of JavaTools::Javac.
def javac( source_files, options = nil )
  obj = JavaTools::Javac.new(*source_files)
  
  if block_given?
    yield obj
  elsif options
    JavaTools::configure_command(obj, options)
  end
  
  obj.execute
end

# Jar can be run in either command or yield mode: command mode
# looks roughly like this:
#
#   jar 'output.jar', [file1, file2], :base_dir => 'build'
#
# and yield mode like this:
#
#   jar('output.jar', [file1, file2]) do |conf|
#     conf.base_dir = 'build'
#   end
#
# In command mode you pass a hash with the configuration directives
# (listed below) and in yield mode an object is passed to the block,
# and the configuration directives should be set on that.
#
# The possible configuration directives are:
# * base_dir
# * compression
# * verbose
#
# The directives are the same as the properties of JavaTools::Javac.
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