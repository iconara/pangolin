task :default => :spec


# Import all .rake-files in the tasks directory
Dir['tasks/*.rake'].each do |tasks_file|
  begin
    load tasks_file
  rescue Exception => e
    $stderr.puts e.message
  end
end