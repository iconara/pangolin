# encoding: utf-8

require 'java'


module Pangolin

  include_class 'java.io.FileOutputStream'
  include_class 'java.util.zip.ZipOutputStream'
  include_class 'java.util.zip.ZipEntry'
  
  class Jar  
    include JarCommon
    
    def create_zipfile # :nodoc:
      buffer_size = 65536
      
      zipstream = ZipOutputStream.new(FileOutputStream.new(@output))
      
      @entries.each do |path, entry|
        io = entry.open
        while buffer = io.read(buffer_size)
          zipstream.put_next_entry(ZipEntry.new(path))
          zipstream.write(buffer.to_java_bytes, 0, buffer.length)
          zipstream.close_entry
        end
        io.close
      end
            
      zipstream.close
    end
  end
end