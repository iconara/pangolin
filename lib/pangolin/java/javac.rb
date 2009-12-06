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
    
    def execute_compiler(io)
      output_writer = StringWriter.new
      
      compiler.compile(command_args.to_java(java.lang.String), PrintWriter.new(output_writer))
      
      io.print(format_output(output_writer.to_s))
    end
    
  private

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

  end
  
end