# encoding: utf-8

module Pangolin
  class Junit
    include JunitCommon
    
    def execute(io=$stderr)
      raise 'No tests' if @class_names.nil? || @class_names.empty?
      
      class_path_str = (@class_path + [JUNIT_JAR_PATH]).join(':')
      test_classes   = @class_names.join(' ')
      
      output = %x(java -classpath #{class_path_str} org.junit.runner.JUnitCore #{test_classes} 2>&1)
      
      print_result(io, output)
      
      $?.success?
    end
    
    def print_result(io, output)
      num_tests, num_failures, time_taken = 0, 0, 0
      
      if output =~ /Time: (\d+\.\d+)/.match(output)
        time_taken = ($1.to_f * 1000).to_i
      end
      
      if output =~ /There was (\d+) failure/
        num_failures = $1.to_i
      end
      
      if output =~ /Tests run: (\d+)/
        num_tests = $1.to_i
      end
      
      print_header(io, num_tests, num_failures, time_taken)
      
      output.scan(/\d+\) (\w+\([^\)]+\))\n(.+?)\n(.+?)\n\n/m) do |match|
        print_failure(io, match[0], match[1], match[2])
      end
    end
    
  end
end