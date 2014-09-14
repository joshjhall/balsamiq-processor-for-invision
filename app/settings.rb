require 'json'
require 'fileutils'

# Simple class to load up the settings file in one place

class Settings
  # Initialize variables needed
  def initialize
    # Import the base settings
    @settings = File.open('config/settings.json', 'r'){|f| JSON.load(f)} || Array.new
    
    # Replace ~ with the appropriate HOME variable to leverage common conventions in settings
    @settings['accountRoot'] = Shellwords.escape(@settings['accountRoot'].gsub(/~/, ENV['HOME']))
    @settings['balsamiqBin'] = Shellwords.escape(@settings['balsamiqBin'].gsub(/~/, ENV['HOME']))
    
    # Build the full path to the site assets project, and escape ~ with HOME variable
    @settings['componentsProject'] = Shellwords.escape(@settings['accountRoot'] + "/" + @settings['componentsProject'].gsub(/~/, ENV['HOME']) + "/Assets/Wireframes")
  end
  
  def get
    return @settings
  end
end
