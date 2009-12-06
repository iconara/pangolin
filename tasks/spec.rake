require 'spec/rake/spectask'
  

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts << '--options' << 'spec/spec.opts'
  spec.ruby_opts << '-rpangolin'
#  spec.warning = true
end