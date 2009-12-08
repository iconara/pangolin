# encoding: utf-8

module Pangolin
  class Javac
    include JavacCommon
    
    def execute_compiler(io)
      output = %x(javac #{command_args.join(' ')} 2>&1)
      
      io.puts(format_output(output))
      
      $?.success?
    end
  end
end