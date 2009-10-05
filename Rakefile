require 'rake/clean'


task :default => :prepare

task :prepare do
  require 'open-uri'
  
  junit_url = "http://downloads.sourceforge.net/project/junit/junit/4.7/junit-4.7.jar"
  ext_dir   = 'lib/java_tools/ext'
  
  mkdir_p ext_dir
  
  $stderr.print 'Downloading JUnit 4.7... '
  
  File.open("#{ext_dir}/junit.jar", 'w') do |f|
    f.write(open(junit_url).read)
  end
  
  $stderr.puts 'done'
end

# This is a workaround for a silly bug in RubyGems on JRuby:
# when running a rakefile as part of an install the 2>&1 redirect ends
# ends up as an argument to Rake, and Rake complains, which makes the
# build fail. The workaround is to declare a task with this name.
task '2>&1' => :default


# Import all .rake-files in the tasks directory
Dir['tasks/*.rake'].each do |tasks_file|
  begin
    load tasks_file
  rescue Exception => e
    $stderr.puts e.message
  end
end