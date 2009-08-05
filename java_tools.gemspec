# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{java_tools}
  s.version = "0.1.0"
  s.platform = %q{java}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Theo Hultberg"]
  s.date = %q{2009-08-05}
  s.description = %q{Ant is a nice tool for writing Java build scripts, but Rake is nicer. The only thing missing from Rake is a way to run javac and jar, and although it's easy to run these as shell scripts you have to wait for the JVM to start. In combination with JRuby this gem lets you run javac and jar in your Rake scripts without exec'ing.}
  s.email = %q{theo@iconara.net}
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    "README.textile",
     "Rakefile",
     "VERSION",
     "examples/compile/Rakefile",
     "examples/compile/src/com/example/HelloWorld.java",
     "examples/package/Rakefile",
     "examples/package/src/com/example/HelloWorld.java",
     "java_tools.gemspec",
     "lib/java_tools.rb",
     "lib/java_tools/jar.rb",
     "lib/java_tools/javac.rb",
     "spec/jar_cmd_spec.rb",
     "spec/jar_spec.rb",
     "spec/javac_cmd_spec.rb",
     "spec/javac_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "tasks/gem.rake",
     "tasks/spec.rake"
  ]
  s.homepage = %q{http://github.com/iconara/java_tools}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Ruby wrappers for javac and jar that don't just exec}
  s.test_files = [
    "spec/jar_cmd_spec.rb",
     "spec/jar_spec.rb",
     "spec/javac_cmd_spec.rb",
     "spec/javac_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
