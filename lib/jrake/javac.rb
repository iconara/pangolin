require 'java'


module JRake

  # must use include_class instead of import because import interferes with Rake's import
  include_class 'java.io.PrintWriter'
  include_class 'java.io.StringWriter'


  class Javac

    attr_accessor :source_files,         # array
                  :source_path,          # array
                  :destination,          # string
                  :class_path,           # array
                  :deprecation_warnings, # boolean
                  :warnings,             # boolean
                  :encoding,             # string
                  :verbose               # boolean

    def initialize( *source_files )
      @source_files = source_files || [ ]
  
      @source_path          = [ ]
      @destination          = 'build'
      @class_path           = [ ]
      @deprecation_warnings = true
      @warnings             = true
      @encoding             = nil
      @verbose              = false
    end

    def command_args
      args = [ ]
      
      args << '-sourcepath' << @source_path.join(':') unless @source_path.empty?
      
      args << '-d' << @destination unless (@destination.nil? || @destination =~ /^\s*$/)
      
      args << '-classpath' << @class_path.join(':') unless @class_path.empty?
      
      args << '-deprecation' unless @deprecation_warnings
      
      args << '-nowarn' unless @warnings
      
      args << '-encoding' << @encoding if @encoding
      
      args + @source_files
    end
  
    def command_string
      'javac ' + command_args.join(' ')
    end

    def execute( io = $stderr )
      output_writer = StringWriter.new
  
      args = command_args.to_java(java.lang.String)
  
      result = com.sun.tools.javac.Main.compile(args, PrintWriter.new(output_writer))
      
      io.puts command_string if @verbose
      
      output_str = output_writer.to_s
      
      io.puts output_str if output_str !~ /^\s*$/
  
      if 0 == result
        true
      else
        false
      end
    end

  end
  
end