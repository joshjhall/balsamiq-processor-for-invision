require 'pathname'
require 'fileutils'
require './app/log.rb'
require './app/settings.rb'

# Exports BMML to PNG for InVision integration

class ExportBmml
  # Initialize variables needed
  def initialize
    # Instantiate settings
    s = Settings.new
    @settings = s.get
    
    # Instantiate @log class to log events
    @log = LogInfo.new @settings['exportLog']
  end
  
  
  # Get the PNG related to a BMML file
  def png(file)
    # Define the output file based on the input
    # 1. Move to screens directory
    # 2. Change extension from bmml to png
    # 3. Remove any sub-directories under Screens, because InVision will ignore them
    output = file.gsub(/\/Assets\/Wireframes\//, '/Screens/').gsub(/\.bmml/, '.png').gsub(/\/Screens\/.*\/([^\/]*\.png)/, '/Screens/\1')
    
    return output
  end
  
  
  # Clean out old PNG file
  def clean(file)
    # Make sure we have the absolute path
    file = File.absolute_path file
    
    # Log what is about to be processed
    puts @log.info "Deleting output for `" + File.basename(file) + "`"
    
    File.delete png(file)
  end
  
  
  # Export the BMML file passed
  # file = path to a .bmml file
  def file(file)
    # Make sure we have the absolute path
    file = File.absolute_path file
    
    # Log what is about to be processed
    puts @log.info "Processing file `" + File.basename(file) + "`"
    
    # Clean up the filename entered to ensure proper escaping
    input = Shellwords.escape(file)
    
    # Get and cleanup the filename for the related PNG
    output = Shellwords.escape(png(file))
    
    # Join elements for the final output component of the command
    cmd = "#{@settings['balsamiqBin']} export #{input} #{output}"
    
    result = `#{cmd}`
    # Run the command with bash in a thread (hopefully this will mitigate race conditions, but needs further testing)
    # t = Thread.new {
    #   Thread.current["run"] = cmd
    #   Thread.current["result"] = `#{Thread.current["run"]}`
    # }
  end
  
  
  # Export all BMML for the project passed
  def project(project)
    # Change working directory to accountRoot
    Dir.chdir project do
      # Log beginning of project export
      puts @log.info "Begin exporting project `" + project + "`"
      
      # Locate all BMML files to export
      bmmlFiles = File.join("**", "*.bmml")
    
      # Walk through all available BMML files
      Dir.glob(bmmlFiles).each do |f|
        # Ignore .bmml files in the asset directory
        unless f =~ /\/Wireframes.*\/assets\//
          # Export all of the bmml files found
          # file File.absolute_path f
          file f
        end
      end
      
      # Log completion of project
      puts @log.info "Done exporting project `" + project + "`"
    end
  end
  
  
  # Do a fresh export of all project wireframes
  # Useful during startup to recover from export errors
  def all
    # Change working directory to accountRoot
    Dir.chdir @settings['accountRoot'] do
      # Log beginning of complete export
      puts @log.info "Begin exporting all projects"
      
      # Locate all BMML files to export
      bmmlFiles = File.join("**", "*.bmml")
    
      # Walk through all available BMML files
      Dir.glob(bmmlFiles).each do |f|
        # Ignore .bmml files in the asset directory
        unless f =~ /\/Wireframes.*\/assets\//
          # Export all of the bmml files found
          file f
        end
      end
      
      # Log completion of export
      puts @log.info "Done exporting all projects"
    end
  end
end
