require 'java'


module JavaTools

  include_class 'java.io.FileOutputStream'
  include_class 'java.util.zip.ZipOutputStream'
  include_class 'java.util.zip.ZipEntry'
  

  class Jar
  
    attr_accessor :base_dir,    # string
                  :compression, # number (0-9)
                  :verbose      # boolean
                  
    attr_reader :output
                
    def initialize( output, files = nil, base_dir = nil )
      @output      = output
      @base_dir    = base_dir
      @entries     = { } # archive_path => JarEntry
      @verbose     = false
      @compression = 1
      
      self.manifest = { }
      
      add_files(files) unless files.nil? || files.empty?
    end
  
    def manifest=( manifest_hash )
      @manifest = default_manifest
      
      manifest_hash.each do |key, value|
        raise ArgumentError, "Malformed attribute name #{key}" if key !~ /^[\w\d][\w\d\-_]*$/
        
        remove_manifest_attribute(key)
        
        @manifest[key] = value
      end
    end
    
    def remove_manifest_attribute( name )
      @manifest.delete_if do |key, value|
        key.downcase == name.downcase
      end      
    end
    
    def main_class=( class_name )
      if class_name
        @manifest['Main-Class'] = class_name
      else
        remove_manifest_attribute('Main-Class')
      end
    end
    
    def default_manifest
      {
        'Built-By' => "JavaTools v#{JavaTools::version}",
        'Manifest-Version' => '1.0'
      }
    end
    
    def manifest_string
      @manifest.keys.inject("") do |str, key|
        str + "#{key}: #{@manifest[key]}\n"
      end
    end
    
    def commit_manifest
      add_blob(manifest_string, 'META-INF/MANIFEST.MF')
    end
    
    def add_file( file_path, archive_path = nil )
      archive_path = find_archive_path(file_path, @base_dir) unless archive_path
      
      if File.directory?(file_path)
        raise ArgumentError, "\"#{file_path}\" is a directory"
      elsif ! File.exists?(file_path)
        raise ArgumentError, "\"#{file_path}\" does not exist"
      end
      
      @entries[archive_path || file_path] = File.new(file_path)
    end
    
    def add_files( files, base_dir = nil )
      files.each do |file|
        add_file(file, find_archive_path(file, base_dir || @base_dir))
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
    
    def execute( io = $stderr )
      raise "Output not set" unless @output
      
      compression_flag = @compression == 0 ? '0' : ''
      
      io.puts "jar -c#{compression_flag}f #{@output} …" if @verbose
      
      commit_manifest
      create_zipfile
    end
    
    def create_zipfile
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
    
  end
  
end