# encoding: utf-8

require 'stringio'


module Pangolin
  module JarCommon

    # The path to the directory which should be considered the root of the archive.
    #
    # If you set +base_dir+ to "build" and add the file "build/Main.class", that file
    # will be put in the archive as "Main.class". 
    attr_accessor :base_dir
    
    # The ZIP compression rate from 0 (no compression) to 9 (maximal compression)
    attr_accessor :compression
    
    # Whether or not to print the equivalent command string to the output (see #execute)
    attr_accessor :verbose
    
    # The path to the JAR file that will be generated
    attr_reader :output
    
    def initialize( output, files = nil, base_dir = nil )
      @output      = output
      @base_dir    = base_dir
      @entries     = { } # archive_path => {String,File}Entry
      @verbose     = false
      @compression = 1
      
      self.manifest = { }
      
      add_files(files) unless files.nil? || files.empty?
    end
    
    # Sets the attributes that will end up in the JAR manifest.
    #
    # Attribute names are treated case insensitively, so setting
    # both Main-Class and main-class will result in only one being used.
    #
    # Will raise an error on malformed attribute names (must start with a
    # letter or digit and contain only letter, digits, dashes and underscores).
    # 
    # The manifest you set will be merged with a set of default attributes (but
    # yours will override).
    def manifest=( manifest_hash )
      @manifest = default_manifest
      
      manifest_hash.each do |key, value|
        raise ArgumentError, "Malformed attribute name #{key}" if key !~ /^[\w\d][\w\d\-_]*$/
        
        remove_manifest_attribute(key)
        
        @manifest[key] = value
      end
    end
    
    # Removes a manifest attribute, the comparison is case insensitive.
    def remove_manifest_attribute( name ) # :nodoc:
      @manifest.delete_if do |key, value|
        key.downcase == name.downcase
      end
    end
    
    # Convenience method for setting the Main-Class manifest attribute
    def main_class=( class_name )
      if class_name
        @manifest['Main-Class'] = class_name
      else
        remove_manifest_attribute('Main-Class')
      end
    end
    
    def default_manifest # :nodoc:
      {
        'Built-By' => "Pangolin v#{Pangolin::version}",
        'Manifest-Version' => '1.0'
      }
    end
    
    def manifest_string # :nodoc:
      @manifest.keys.inject("") do |str, key|
        str + "#{key}: #{@manifest[key]}\n"
      end
    end
    
    def commit_manifest # :nodoc:
      add_blob(manifest_string, 'META-INF/MANIFEST.MF')
    end
    
    # Adds the file at +file_path+ to the archive and put it at +archive_path+
    # (the same as +file_path+ by default) inside the archive.
    def add_file( file_path, archive_path = nil )
      archive_path = find_archive_path(file_path, @base_dir) unless archive_path
      
      if File.directory?(file_path)
        raise ArgumentError, "\"#{file_path}\" is a directory"
      elsif ! File.exists?(file_path)
        raise ArgumentError, "\"#{file_path}\" does not exist"
      end
      
      @entries[archive_path || file_path] = FileEntry.new(file_path)
    end
    
    # Adds a list of files to the archive, at paths relative to +base_dir+
    # (defaults to #base_dir) inside the archive.
    def add_files( files, base_dir = nil )
      files.each do |file|
        add_file(file, find_archive_path(file, base_dir || @base_dir))
      end
    end
    
    # Adds a string to the archive at +archive_path+.
    def add_blob( str, archive_path )
      @entries[archive_path] = StringEntry.new(str)
    end
    
    def remove_entry( archive_path ) # :nodoc:
      @entries.delete(archive_path)
    end
    
    def entries # :nodoc:
      @entries.keys
    end
    
    # Creates the archive. If #verbose is true the equivalent command string
    # for the +jar+ command will be printed to the stream passed as +io+ (or
    # +$stdout+ by default)
    def execute( io = $stderr )
      raise "Output not set" unless @output
      
      compression_flag = @compression == 0 ? '0' : ''
      
      io.puts 'jar …' if @verbose
      
      commit_manifest
      create_zipfile
      
      true
    end
    
    def find_archive_path( path, base_dir ) # :nodoc:
      if base_dir
        prefix = base_dir + (base_dir =~ /\/$/ ? '' : '/')
      
        if 0 == path.index(prefix)
          return path.slice(prefix.length, path.length - prefix.length)
        end
      end
      
      path
    end
    
    class StringEntry
      def initialize(str)
        @str = str
      end
      def open
        io = StringIO.new(@str)
        if block_given?
          yield io
        else
          io
        end
      end
      def close
      end
    end
    
    class FileEntry
      def initialize(path)
        @path = path
      end
      def open(&block)
        if block_given?
          File.open(@path, 'r', &block)
        else
          @io = File.new(@path)
        end
      end
      def close
        @io.close
      end
    end
  end
end