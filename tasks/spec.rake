# encoding: utf-8

require 'spec/rake/spectask'
  

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts << '--options' << 'spec/spec.opts'
  spec.pattern = 'spec/*_spec.rb'
end

Spec::Rake::SpecTask.new(:intg_spec) do |spec|
  spec.spec_opts << '--options' << 'spec/spec.opts'
  spec.pattern = 'spec/integration/*_spec.rb'
end

desc 'Run specs and integration specs in all available versions of Ruby'
task :multitest do
  ['ruby', 'ruby1.9', 'jruby'].each do |r|
    if %x(which #{r}) && $?.success?
      started_at = Time.now
      
      $stderr.print "#{r}... "
      
      cmd  = r
      cmd += ' --client' if cmd == 'jruby'
      
      output = %x(#{cmd} -S rake spec intg_spec 2>&1)
      
      if $?.success?
        time_taken = ((Time.now.to_f - started_at.to_f) * 10).round/10.0
        
        $stderr.puts "done (#{time_taken} s)"
      else
        $stderr.puts 'failed:'
        $stderr.puts output

        raise "Tests failed in #{%x(#{r} --version)}"
      end
    else
      $stderr.puts "#{r} not available"
    end
  end
end