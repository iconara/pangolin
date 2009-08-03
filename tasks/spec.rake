require 'spec/rake/spectask'
  

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts << '--options' << 'spec/spec.opts'
  spec.libs << 'lib'
  spec.ruby_opts << '-rjava_tools'
  spec.warning = true
end