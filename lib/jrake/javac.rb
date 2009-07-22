require File.dirname(__FILE__) + '/abstract_tool'


class Javac < AbstractTool
  
  attr_accessor :source_files,
                :source_path,
                :destination,
                :class_path,
                :deprecation_warnings,
                :warnings,
                :encoding

  def initialize( source_files = [ ] )
    @source_files = source_files
    
    @source_path          = ['src']
    @destination          = 'build'
    @class_path           = [ ]
    @deprecation_warnings = true
    @warnings             = true
    @encoding             = nil
  end
  
  def source_path_options
    if @source_path.empty?
      ""
    else
      "-sourcepath #{@source_path.join(':')}"
    end
  end
  
  def destination_options
    if @destination.nil? || @destination =~ /^\s*$/
      ""
    else
      "-d #{@destination}"
    end
  end
  
  def source_files_options
    @source_files.join(' ')
  end
  
  def class_path_options
    if @class_path.empty?
      ""
    else
      "-classpath #{@class_path.join(':')}"
    end
  end
  
  def deprecation_warnings_options
    if @deprecation_warnings
      ""
    else
      "-deprecation"
    end
  end
  
  def warnings_options
    if @warnings
      ""
    else
      "-nowarn"
    end
  end
  
  def encoding_options
    if @encoding
      "-encoding #{@encoding}"
    else
      ""
    end
  end

  def command_string_components
    [
      source_path_options,
      destination_options,
      class_path_options,
      deprecation_warnings_options,
      warnings_options,
      encoding_options,
      source_files_options
    ]
  end
  
end