# encoding: utf-8

module Pangolin
  module JunitCommon
    include Output::Formatting
    
    JUNIT_JAR_PATH = File.expand_path(File.dirname(__FILE__) + '/../ext/junit.jar')    
    
    attr_accessor :class_path
    attr_accessor :colorize
    attr_accessor :verbose
    
    def initialize(*classes)
      @class_names = classes || [ ]
      @class_path  = [ ]
      @colorize    = false
      @verbose     = false
    end
  
    def classes
      @class_names
    end
    
    def print_header(io, num_tests, num_failures, time_taken)
      if num_failures == 0
        io.puts(format_header('%d tests run in %.1f seconds, no failures' % [num_tests, time_taken/1000]))
      else
        args = [
          num_tests,
          time_taken/1000,
          num_failures, 
          num_failures == 1 ? '' : 's'
        ]
        
        io.puts(format_header('%d tests run in %.1f seconds with %d failure%s' % args))
        io.puts('')
      end
    end
    
    def print_failure(io, test_header, message, backtrace)
      io.puts(format_error_header('- ' + test_header))
      io.puts(format_error('  ' + message)) unless message.nil? || message =~ /^\s*$/
      
      filtered_stack_trace_array(backtrace).each do |trace_frame|
        io.puts(format_stack_trace('  ' + trace_frame.strip))
      end
      
      io.puts('')
    end
    
    def filtered_stack_trace_array(trace)
      trace.split("\n").reject do |line|
        case line
        when /java.lang.AssertionError/, /at org.junit/, /at sun.reflect/, /at java.lang.reflect/, /at org.jruby/, /jrake/
          true
        else
          false
        end
      end
    end
    
  end
end