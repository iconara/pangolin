require 'java'
require 'pp'


module JRake

  include_class 'java.io.FileOutputStream'
  include_class 'java.util.zip.ZipOutputStream'
  include_class 'java.util.zip.ZipEntry'
  

  class Jar
  
    attr_accessor :output,      # path
                  :base_dir,    # path
                  :files,       # array
                  :compression, # number (0-9)
                  :verbose      # boolean
                
    def initialize( *files )
      @files = files || [ ]
    
      @output      = nil
      @base_dir    = '.'
      @manifest    = default_manifest
      @compression = 1
      @verbose     = false
    end
  
    def default_manifest
      {
        'Built-By' => 'JRake'
      }
    end
    
    def add_manifest_attribute( name, value )
      if name =~ /^[A-Za-z0-9][A-Za-z0-9\-_]*$/
        @manifest[name] = value
      else
        raise ArgumentError, "Malformed attribute name: #{name}"
      end
    end
    
    def remove_manifest_attribute( name )
      @manifest.delete(name)
    end
    
    def main_class=( class_name )
      if class_name
        add_manifest_attribute('Main-Class', class_name)
      else
        remove_manifest_attribute('Main-Class')
      end
    end
    
    def execute( io = $stderr )
      io.puts "jar ..." if @verbose
      
      create_zipfile
    end
    
    def create_zipfile
      zipstream = ZipOutputStream.new(FileOutputStream.new(@output))
      
      @files.each do |file|
        f = File.new(file)
        
        while buffer = f.read(65536)
          zipstream.put_next_entry(ZipEntry.new(archive_path(file)))
          zipstream.write(buffer.to_java_bytes, 0, buffer.length)
          zipstream.close_entry
        end
        
        f.close
      end
      
      manifest_str = manifest
      
      zipstream.put_next_entry(ZipEntry.new('META-INF/MANIFEST.MF'))
      zipstream.write(manifest_str.to_java_bytes, 0, manifest_str.length)
      zipstream.close_entry
      
      zipstream.close
    end
    
    def archive_path( path )
      if @base_dir
        prefix = @base_dir + (@base_dir =~ /\/$/ ? '' : '/')
      
        if 0 == path.index(prefix)
          return path.slice(prefix.length, path.length - prefix.length)
        end
      end
      
      path
    end
    
    def manifest
      @manifest.keys.inject("") do |str, key|
        str + "\n#{key}: #{@manifest[key]}"
      end + "\n"
    end
  
  end
  
end