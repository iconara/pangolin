require 'java'


module JavaTools

  # must use include_class instead of import because import interferes with Rake's import
  include_class 'java.io.PrintWriter'
  include_class 'java.io.StringWriter'


  class Javac

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
  
    def command_args # :nodoc:
      args = [ ]
      args << '-sourcepath' << formatted_path(@source_path) unless @source_path.empty?
      args << '-d' << @destination unless (@destination.nil? || @destination =~ /^\s*$/)
      args << '-classpath' << formatted_path(@class_path) unless @class_path.empty?
      args << '-deprecation' unless @deprecation_warnings
      args << '-nowarn' unless @warnings
      args << '-encoding' << @encoding if @encoding
      args + @source_files
    end
  
    def command_string # :nodoc:
      args = [ ]
      args << '-sourcepath' << formatted_path(@source_path) unless @source_path.empty?
      args << '-d' << @destination unless (@destination.nil? || @destination =~ /^\s*$/)
      args << '-classpath' << formatted_path(@class_path) unless @class_path.empty?
      args << '-deprecation' unless @deprecation_warnings
      args << '-nowarn' unless @warnings
      args << '-encoding' << @encoding if @encoding

      "javac #{args.join(' ')} …"
    end

    # Run javac. If #verbose is true the equivalent command string for
    # the +javac+ command will be printed to the stream passed as +io+ (or
    # +$stdout+ by default)
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
    
  private
    
    def formatted_path(items)
      if items.respond_to? :join
        items.join(':')
      else
        items.to_s
      end
    end

  end
  
end