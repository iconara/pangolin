# encoding: utf-8

module Pangolin
  
  module JavacCommon
    
    include ::Pangolin::Output::Formatting
    
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
    
    # Run javac. If #verbose is true the equivalent command string for
    # the +javac+ command will be printed to the stream passed as +io+ (or
    # +$stdout+ by default)
    def execute( io = $stderr )
      raise 'No source files' if @source_files.nil? || @source_files.empty?
  
      io.puts 'javac …' if @verbose
  
      execute_compiler(io)
    end

    def lint_flags
      @lint.map { |lint| '-Xlint:' + lint }
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