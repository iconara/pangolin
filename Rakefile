require 'spec/rake/spectask'


task :default => :spec


Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts << '--options' << 'spec/spec.opts'
  spec.libs << 'src'
  spec.warning = true
end