require File.expand_path(File.dirname(__FILE__)) + '/java_tools/javac'
require File.expand_path(File.dirname(__FILE__)) + '/java_tools/jar'


def javac( source_files )
  javac = JavaTools::Javac.new(*source_files)
  
  yield javac
  
  javac.execute
end

def jar( output )
  jar = JavaTools::Jar.new(output)
  
  yield jar
  
  jar.execute
end