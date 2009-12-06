require 'tmpdir'
require 'fileutils'
require 'digest/md5'

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Jar do
  
  context 'a created jar file' do
    before do
      @output_dir = File.join(Dir.tmpdir, "jar_spec_#{rand(1000)}")      
      @output_file = File.join(@output_dir, 'package.jar')
      @base_dir = File.dirname(__FILE__) + '/data/classes'
      @files = Dir["#{@base_dir}/**/*.class"]
      @jar = Jar.new(@output_file, @files, @base_dir)
      @jar.manifest = {'Hello' => 'World', 'Foo' => 'Bar'}
      
      Dir.mkdir(@output_dir)
      
      @jar.execute
    end
    
    after do
      FileUtils.rm_rf(@output_dir)
    end
    
    context 'unpacked' do
      before do
        %x(cd #{@output_dir} && jar -xf #{@output_file})
      end
      
      it 'can be unpacked' do
        Dir[@output_dir + '/**/*.class'].should_not be_empty
      end
      
      it 'contains a manifest with all attributes' do
        manifest = File.read(File.join(@output_dir, 'META-INF', 'MANIFEST.MF'))
        manifest.should include('Hello: World')
        manifest.should include('Foo: Bar')
      end
      
      it 'contains the same files' do
        @original = @base_dir + '/com/example/HelloWorld.class'
        @extracted = @output_dir + '/com/example/HelloWorld.class'
        
        @original_digest = Digest::MD5.hexdigest(File.read(@original))
        @extracted_digest = Digest::MD5.hexdigest(File.read(@extracted))
        
        @original_digest.should == @extracted_digest
      end
    end
    
    context 'table of contents' do
      it 'contains all files' do
        file_listing = %x(jar -tf #{@output_file})
        file_listing.should include('com/example/HelloWorld.class')
      end
    
      it 'contains a manifest' do
        file_listing = %x(jar -tf #{@output_file})
        file_listing.should include('META-INF/MANIFEST.MF')
      end
    end
  end
  
end