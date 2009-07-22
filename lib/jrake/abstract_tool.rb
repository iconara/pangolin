class AbstractTool
  
  def command_string_components
    []
  end
  
  def command_string
    command_string_components.reject { |opts| opts =~ /^\s*$/ }.join(' ')
  end
  
  def execute
    
  end
  
end