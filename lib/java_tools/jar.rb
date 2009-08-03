require 'java'


module JavaTools

  include_class 'java.io.FileOutputStream'
  include_class 'java.util.zip.ZipOutputStream'
  include_class 'java.util.zip.ZipEntry'
  

  class Jar
  
    attr_accessor :output,      # path
                  :base_dir,    # path
                  :compression, # number (0-9)
                  :verbose      # boolean
                
    def initialize( output = nil )
      @output = output
      
      @entries     = { } # archive_path => JarEntry
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
        remove_manifest_attribute(name)
        
        @manifest[name] = value
      else
        raise ArgumentError, "Malformed attribute name: #{name}"
      end
    end
    
    def remove_manifest_attribute( name )
      @manifest.delete_if { |key, value| key.downcase == name.downcase }
    end
    
    def add_file( file_path, archive_path = nil )
      if File.directory?(file_path)
        raise ArgumentError, "\"#{file_path}\" is a directory"
      elsif ! File.exists?(file_path)
        raise ArgumentError, "\"#{file_path}\" does not exist"
      end
      
      @entries[archive_path || file_path] = File.new(file_path)
    end
    
    def add_files( files, base_dir = nil )
      files.each do |file|
        add_file(file, find_archive_path(file, base_dir))
      end
    end
    
    def add_blob( str, archive_path )
      @entries[archive_path] = StringIO.new(str)
    end
    
    def remove_entry( archive_path )
      @entries.delete(archive_path)
    end
    
    def entries
      @entries.keys
    end
    
    def main_class=( class_name )
      if class_name
        add_manifest_attribute('Main-Class', class_name)
      else
        remove_manifest_attribute('Main-Class')
      end
    end
    
    def execute( io = $stderr )
      compression_flag = @compression == 0 ? '0' : ''
      
      io.puts "jar -c#{compression_flag}f #{@output} …" if @verbose
      
      create_zipfile
    end
    
    def create_zipfile
      add_blob(manifest, 'META-INF/MANIFEST.MF')
      
      buffer_size = 65536
      
      zipstream = ZipOutputStream.new(FileOutputStream.new(@output))
      
      @entries.each do |path, io|
        while buffer = io.read(buffer_size)
          zipstream.put_next_entry(ZipEntry.new(path))
          zipstream.write(buffer.to_java_bytes, 0, buffer.length)
          zipstream.close_entry
        end
        
        io.close
      end
            
      zipstream.close
    end
    
    def find_archive_path( path, base_dir )
      if base_dir
        prefix = base_dir + (base_dir =~ /\/$/ ? '' : '/')
      
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