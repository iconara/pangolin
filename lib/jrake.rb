require File.expand_path(File.dirname(__FILE__)) + '/jrake/javac'
require File.expand_path(File.dirname(__FILE__)) + '/jrake/jar'


def javac( source_files )
  javac = JRake::Javac.new(source_files)
  
  yield javac
  
  javac.execute
end

def jar( files )
  jar = JRake::Jar.new(files)
  
  yield jar
  
  jar.execute
end