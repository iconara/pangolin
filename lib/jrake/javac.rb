require 'java'

require File.dirname(__FILE__) + '/abstract_tool'


module JRake

  # must use include_class instead of import because import interferes with Rake's import
  include_class 'java.io.PrintWriter'
  include_class 'java.io.StringWriter'


  class Javac < AbstractTool  

    attr_accessor :source_files,         # array
                  :source_path,          # array
                  :destination,          # string
                  :class_path,           # array
                  :deprecation_warnings, # boolean
                  :warnings,             # boolean
                  :encoding              # string

    def initialize( *source_files )
      @source_files = source_files || [ ]
  
      @source_path          = ['src']
      @destination          = 'build'
      @class_path           = [ ]
      @deprecation_warnings = true
      @warnings             = true
      @encoding             = nil
    end

    def source_path_options
      if @source_path.empty?
        ""
      else
        "-sourcepath #{@source_path.join(':')}"
      end
    end

    def destination_options
      if @destination.nil? || @destination =~ /^\s*$/
        ""
      else
        "-d #{@destination}"
      end
    end

    def source_files_options
      @source_files.join(' ')
    end

    def class_path_options
      if @class_path.empty?
        ""
      else
        "-classpath #{@class_path.join(':')}"
      end
    end

    def deprecation_warnings_options
      if @deprecation_warnings
        ""
      else
        "-deprecation"
      end
    end

    def warnings_options
      if @warnings
        ""
      else
        "-nowarn"
      end
    end

    def encoding_options
      if @encoding
        "-encoding #{@encoding}"
      else
        ""
      end
    end

    def command_args
      [
        source_path_options,
        destination_options,
        class_path_options,
        deprecation_warnings_options,
        warnings_options,
        encoding_options,
        source_files_options
      ].reject { |opts| opts =~ /^\s*$/ }
    end
  
    def command_string
      'javac ' + command_args.join(' ')
    end

    def execute
      output_writer = StringWriter.new
  
      args = command_args.to_java(java.lang.String)
  
      result = com.sun.tools.javac.Main.compile(args, PrintWriter.new(output_writer))
  
      if 0 == result
        puts output_writer.to_s
      else
        raise "Compilation failed"
      end
    end

  end
  
end