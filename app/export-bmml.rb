require 'pathname'
require 'fileutils'
require './app/log.rb'
require './app/settings.rb'
require './app/index.rb'

# Exports BMML to PNG for InVision integration

class ExportBmml
  # Initialize variables needed
  def initialize
    # Instantiate settings
    s = Settings.new
    @settings = s.get
    
    # Instantiate @log class to log events
    @log = LogInfo.new @settings['exportLog']
    
    # Instantiate @indexer class to index files
    @index = Index.new
  end
  
  
  # Get the PNG related to a BMML file
  def screenName(f)
    # Define the output file based on the input
    # 1. Move to screens directory
    # 2. Change extension from bmml to png
    # 3. Remove any sub-directories under Screens, because InVision will ignore them
    output = f.gsub(/\/Assets\/Wireframes\//, '/Screens/').gsub(/\.bmml/, '.png').gsub(/\/Screens\/.*\/([^\/]*\.png)/, '/Screens/\1')
    
    output
  end
  
  
  # Clean out old PNG file
  def delete(f)
    # Log what is about to be processed
    puts @log.info "Deleting output for `#{File.basename(f)}`"
    
    # Delete the orphan PNG file
    if File.exist? f
      File.delete screenName(f)
    end
    
    # Make sure we don't have a relative path problem
    f = File.absolute_path f
    if File.exist? f
      File.delete screenName(f)
    end
  end
  
  
  # Export the BMML file passed
  # file: path to a .bmml file
  def file(f, force = false)
    # Make sure we have the absolute path
    f = File.absolute_path f
    
    # Close any open tabs in Balsamiq
    # cmd = `#{@settings['closeWindows']}`
    
    # Only export items that are new or updated
    if @index.updated? f or force
      # Log what is about to be processed
      puts @log.info "Processing file `#{File.basename(f)}`"
      
      # Join elements for the final output component of the command
      cmd = "#{Shellwords.escape(@settings['balsamiqBin'])} export #{Shellwords.escape(f)} #{Shellwords.escape(screenName(f))}"
      
      # Run the export using the Balsamiq desktop client
      result = `#{cmd}`
      
      # Store the hash of the exported file in the indexer for future reference
      @index.update f
    end
  end
  
  
  # Export all files in a directory, and update the appropriate indecies
  def processDir
    # Walk through all project files
    Dir.glob("**/*").each do |f|
      # Only consider file types that we care about, and ignore the Screens dir
      if @settings['fileTypes'].include?((File.extname f).downcase) and \
        not File.dirname(f).end_with?('Screens')
        
        # Only export .bmml files
        if (File.extname f).downcase == '.bmml'
          # Don't export .bmml files in the asset directory
          unless f =~ /\/Wireframes.*\/assets\//
            # Export all of the bmml files found
            file f, true
          end
        end
        
        # Update all of the indecies for the appropriate files in the project
        if @index.updated? File.absolute_path f
          # Store the hash of the exported file in the indexer for future reference
          @index.update File.absolute_path f
        end
      end
    end
  end
  
  
  # Export all BMML for the project passed
  def project(p)
    # Change working directory to accountRoot
    Dir.chdir p do
      # Log beginning of project export
      puts @log.info "Begin exporting project `#{p}`"
      
      # Process the directory
      processDir
      
      # Log completion of project
      puts @log.info "Done exporting project `#{p}`"
    end
  end
  
  
  # Do a fresh export of all project wireframes
  # Useful during startup to recover from export errors
  def all
    # Change working directory to accountRoot
    Dir.chdir @settings['accountRoot'] do
      # Log beginning of complete export
      puts @log.info "Begin exporting all projects"
      
      # Process the directory
      processDir
      
      # Log completion of export
      puts @log.info "Done exporting all projects"
    end
  end
end
