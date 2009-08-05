require 'jeweler'


Jeweler::Tasks.new do |gemspec|
  gemspec.name = "java_tools"
  gemspec.summary = "Ruby wrappers for javac and jar that don't just exec"
  gemspec.description = "Ant is a nice tool for writing Java build scripts, but Rake is nicer. The only thing missing from Rake is a way to run javac and jar, and although it's easy to run these as shell scripts you have to wait for the JVM to start. In combination with JRuby this gem lets you run javac and jar in your Rake scripts without exec'ing."
  gemspec.email = "theo@iconara.net"
  gemspec.homepage = "http://github.com/iconara/java_tools"
  gemspec.authors = ["Theo Hultberg"]
  gemspec.files.exclude '**/.gitignore'
  gemspec.platform = 'java'
end

CLEAN.include('pkg')