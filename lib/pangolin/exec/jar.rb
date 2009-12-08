# encoding: utf-8

require 'zip/zip'


module Pangolin
  class Jar
    include JarCommon
    include Zip
    
    def create_zipfile # :nodoc:
      ZipFile.open(@output, ZipFile::CREATE) do |zipfile|
        @entries.each do |path, io|
          zipfile.get_output_stream(path) do |f|
            f.write(io.read)
          end
        end
      end
    end
  end
end