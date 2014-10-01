require 'json'
require 'shellwords'
require 'fileutils'

# Simple class to load up the settings file in one place

class Settings
  # Initialize variables needed
  def initialize
    # Import the base settings
    @settings = File.open('config/settings.json', 'r'){|f| JSON.load(f)} || Array.new
    
    # Replace ~ with the appropriate HOME variable to leverage common conventions in settings
    @settings['accountRoot'] = @settings['accountRoot'].gsub(/~/, ENV['HOME'])
    @settings['balsamiqBin'] = @settings['balsamiqBin'].gsub(/~/, ENV['HOME'])
    
    # Build the full path to the site assets project, and escape ~ with HOME variable
    @settings['componentsProject'] = "#{@settings['accountRoot']}/" + \
      "#{@settings['componentsProject'].gsub(/~/, ENV['HOME'])}/Assets/Wireframes"
    
    # Put the index file into ./data
    @settings['indexFile'] = File.absolute_path("data/" + @settings['indexFile'])
    
    # Build the full path to the app directory
    @settings['appDir'] = @settings['appDir'].gsub(/~/, ENV['HOME'])
    
    # Build the close windows script call
    @settings['closeWindows'] = "osascript #{Shellwords.escape(File.absolute_path(File.join(@settings['appDir'], @settings['closeWindows'])))}"
  end
  
  def get
    # Return the processed settings variable
    @settings
  end
end
