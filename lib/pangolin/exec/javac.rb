module Pangolin
  class Javac
    include JavacCommon
    
    def execute_compiler(io)
      io.puts(format_output(%x(javac #{command_args.join(' ')} 2>&1)))
    end
  end
end