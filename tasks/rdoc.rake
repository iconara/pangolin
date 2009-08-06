require 'rake/rdoctask'

  
Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'docs'
  rd.title    = 'Java Tools'
  rd.main     = 'README.rdoc'
  
  rd.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
end