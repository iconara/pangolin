require 'java'


module Pangolin
  
  TOOLS_PATHS = [ ]
  TOOLS_PATHS << File.join(ENV['JAVA_HOME'], '..', 'lib', 'tools.jar') if ENV['JAVA_HOME']
  TOOLS_PATHS << File.join(ENV['JAVA_HOME'], 'lib', 'tools.jar') if ENV['JAVA_HOME']

  # must use include_class instead of import because import interferes with Rake's import
  include_class 'java.io.PrintWriter'
  include_class 'java.io.StringWriter'


  class Javac

    include JavacCommon
    include Output::Formatting
    

    # The files to compile.
    attr_accessor :source_files
    
    # Additional directories where source files can be found.
    attr_accessor :source_path
                  
    # The directory where the generated class files should be written, defaults to "build"
    attr_accessor :destination
  
    # The compilation class path
    attr_accessor :class_path
    
    # Show deprecation warnings, true by default
    attr_accessor :deprecation_warnings
    
    # Generate warnings, true by default
    attr_accessor :warnings
    
    # The encoding of the source files
    attr_accessor :encoding
    
    # Whether or not to print the equivalent command string to the output (see #execute)
    attr_accessor :verbose
    
    # Enable or diable specific warnings by adding their names to this list.
    # The possible values are:
    # * all
    # * cast
    # * deprecation
    # * divzero
    # * empty
    # * unchecked
    # * fallthrough
    # * path
    # * serial
    # * finally
    # * overrides
    # * none
    # Prefix with '-' to disable.
    attr_accessor :lint

    # Determines the maximum number of errors to print, default (nil) is to print all
    attr_accessor :max_errors
    
    # Determines the maximum number of warnings to print, default (nil) is to print all
    attr_accessor :max_warnings
    
    attr_accessor :colorize


    def initialize( *source_files )
      @source_files = source_files || [ ]
  
      @source_path          = [ ]
      @destination          = 'build'
      @class_path           = [ ]
      @deprecation_warnings = true
      @warnings             = true
      @encoding             = nil
      @verbose              = false
      @lint                 = [ ]
      @colorize             = false
    end
  
    # Run javac. If #verbose is true the equivalent command string for
    # the +javac+ command will be printed to the stream passed as +io+ (or
    # +$stdout+ by default)
    def execute( io = $stderr )
      raise 'No source files' if @source_files.nil? || @source_files.empty?
      
      output_writer = StringWriter.new
  
      io.puts 'javac …' if @verbose
  
      result = execute_compiler(output_writer)
      
      output_str = output_writer.to_s
      
      io.puts format_output(output_str) if output_str !~ /^\s*$/
  
      if 0 == result
        true
      else
        false
      end
    end
    
    def command_args # :nodoc:
      args = [ ]
      args << '-sourcepath' << formatted_path(@source_path) unless @source_path.empty?
      args << '-d' << @destination unless (@destination.nil? || @destination =~ /^\s*$/)
      args << '-classpath' << formatted_path(@class_path) unless @class_path.empty?
      args << '-deprecation' if @deprecation_warnings
      args << '-nowarn' unless @warnings
      args << '-encoding' << @encoding if @encoding
      args << '-Xmaxerrs' << @max_errors if @max_errors
      args << '-Xmaxwarns' << @max_warnings if @max_warnings 
      args + lint_flags + @source_files
    end
    
  private
  
    def lint_flags
      @lint.map { |lint| '-Xlint:' + lint }
    end
  
    def execute_compiler(output_writer)
      compiler.compile(command_args.to_java(java.lang.String), PrintWriter.new(output_writer))
    end
    
    def compiler
      begin
        return com.sun.tools.javac.Main
      rescue NameError
        TOOLS_PATHS.each do |path|
          if File.exists? path
            require path

            begin
              return com.sun.tools.javac.Main
            rescue NameError
              # ignore and try next
            end
          end
        end
      end
      
      raise 'Could not find com.sun.tools.javac.Main, perhaps tools.jar isn\'t in the class path?'
    end
        
    def formatted_path(items)
      if items.respond_to? :join
        items.join(':')
      else
        items.to_s
      end
    end
    
    def format_output(output)
      output.split(/\n/).map do |line|
        case line
        when /^.+\.java:\d+: warning: .+$/
          format_warning_header(line)
        when /^.+\.java:\d+: .+$/
          format_error_header(line)
        when /^\d+ errors?$/
          format_error(line)
        else
          line
        end
      end.join("\n")
    end

  end
  
end