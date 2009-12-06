module Pangolin # :nodoc:
  
  def self.version # :nodoc:
    version_file = File.join(File.dirname(__FILE__), '..', 'VERSION')
    
    File.open(version_file) do |f|
      f.readline.strip
    end
  end
  
  def self.exec_command( obj, options, block )
    if block
      block.call(obj)
    elsif options
      configure_command(obj, options)
    end

    obj.execute or fail("Execution failed, see above")
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
  
  def self.is_java?
    defined?(JRUBY_VERSION)
  end
  
end

require File.expand_path(File.dirname(__FILE__)) + '/pangolin/common/jar_common'
require File.expand_path(File.dirname(__FILE__)) + '/pangolin/common/javac_common'
require File.expand_path(File.dirname(__FILE__)) + '/pangolin/common/junit_common'
require File.expand_path(File.dirname(__FILE__)) + '/pangolin/output/formatting'

if Pangolin::is_java?
  $stderr.puts 'Warning: JAVA_HOME not set, this may cause problems' unless ENV['JAVA_HOME']
  
  require File.expand_path(File.dirname(__FILE__)) + '/pangolin/java/javac'
  require File.expand_path(File.dirname(__FILE__)) + '/pangolin/java/jar'
  require File.expand_path(File.dirname(__FILE__)) + '/pangolin/java/junit'
  
  class Exception # :nodoc:
    alias exception_backtrace backtrace
  
    # Elide JRuby backtraces to remove all the internal stuff
    def backtrace
      exception_backtrace.reject do |line|
        line =~ /^(org\/jruby|com\/mysql|sun\/|java\/)/
      end
    end
  end
else
  require 'rubygems'
  
  gem 'rubyzip', '>= 0.9.1'
  
  require File.expand_path(File.dirname(__FILE__)) + '/pangolin/exec/javac'
  require File.expand_path(File.dirname(__FILE__)) + '/pangolin/exec/jar'
  require File.expand_path(File.dirname(__FILE__)) + '/pangolin/exec/junit'
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
# * +source_path+
# * +destination+
# * +class_path+
# * +deprecation_warnings+
# * +warnings+
# * +encoding+
# * +verbose+
#
# The directives are the same as the properties of Pangolin::Javac.
#
def javac( source_files, options = nil, &block )
  Pangolin::exec_command(Pangolin::Javac.new(*source_files), options, block)
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
# * +base_dir+
# * +compression+
# * +verbose+
#
# The directives are the same as the properties of Pangolin::Jar.
#
def jar( output, files = nil, options = nil, &block )
  base_dir = nil
  
  if options && options[:base_dir]
    base_dir = options[:base_dir]
  end
  
  Pangolin::exec_command(Pangolin::Jar.new(output, files, base_dir), options, block)
end

# Junit can be run in either command or yield mode: command mode
# looks roughly like this:
#
#   junit ['TestFoo', 'TestBar'], :class_path => ['build']
#
# (where +TestFoo+ and +TestBar+ are classes available from the class path).
#
# Yield mode looks like this:
#
#   junit ['TestFoo', 'TestBar'] do |conf|
#     conf.class_path = ['build']
#   end
#
# In command mode you pass a hash with the configuration directives
# (listed below) and in yield mode an object is passed to the block,
# and the configuration directives should be set on that.
#
# The possible configuration directives are:
# * +class_path+
# * +colorize+
#
# The directives are the same as the properties of Pangolin::Junit.
#
def junit( classes, options = nil, &block )
  Pangolin::exec_command(Pangolin::Junit.new(*classes), options, block)
end