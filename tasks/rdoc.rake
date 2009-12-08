# encoding: utf-8

require 'rake/rdoctask'

  
Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'docs'
  rd.title    = 'Pangolin'
  rd.main     = 'README.rdoc'
  
  rd.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
end