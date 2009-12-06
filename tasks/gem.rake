begin
  require 'jeweler'
  
  CLEAN.include('pkg')
  
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'pangolin'
    gemspec.summary = 'Ruby wrappers for javac and jar that don\'t just exec'
    gemspec.description = 'Ant is a nice tool for writing Java build scripts, but Rake is nicer. The only thing missing from Rake is a way to run javac and jar, and although it\'s easy to run these as shell scripts you have to wait for the JVM to start. In combination with JRuby this gem lets you run javac and jar in your Rake scripts without exec\'ing.'
    gemspec.email = 'theo@iconara.net'
    gemspec.homepage = 'http://github.com/iconara/pangolin'
    gemspec.authors = ['Theo Hultberg']
    gemspec.extensions = 'Rakefile'
    gemspec.files.exclude '**/.gitignore'

    gemspec.add_dependency 'rubyzip', '>= 0.9.1'

    gemspec.add_development_dependency 'rspec'
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler'
end