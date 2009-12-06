require 'spec/rake/spectask'
  

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts << '--options' << 'spec/spec.opts'
  spec.ruby_opts << '-rpangolin'
  spec.pattern = 'spec/*_spec.rb'
end

Spec::Rake::SpecTask.new(:intg_spec) do |spec|
  spec.spec_opts << '--options' << 'spec/spec.opts'
  spec.ruby_opts << '-rpangolin'
  spec.pattern = 'spec/integration/*_spec.rb'
end