require 'pathname'
require 'fileutils'
require './app/log.rb'
require './app/settings.rb'
require './app/export-bmml.rb'
require './app/index.rb'

# Exports all BMMLs that have out-dated PNGs
# Also cleans up any old PNGs that no longer have BMMLs

class Scanner
  # Initialize variables needed
  def initialize
    # Instantiate settings
    s = Settings.new
    @settings = s.get
    
    # Instantiate @log class to log events
    @log = LogInfo.new @settings['scannerLog']
    
    # Instantiate @export to manage exports
    @export = ExportBmml.new
    
    # Instantiate @indexer class to index files
    @index = Index.new
  end
  

  # Testing pieces
  def all
    # Change working directory to accountRoot
    Dir.chdir @settings['accountRoot'] do
      # Log beginning of complete export
      puts @log.info "Scanning all projects"
      
      # Locate all BMML files to export
      bmmlFiles = File.join("**", "*.bmml")
      
      # Walk through all available BMML files
      Dir.glob(bmmlFiles).each do |f|
        # Ignore .bmml files in the asset directory
        unless f =~ /\/Wireframes.*\/assets\//
          # Export all of the bmml files found
          @export.file f
        end
      end
    end
  end
end