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
  
  
  # TODO Also scan for files that have been removed since the last index
  # Scan all projects to update anything new
  def all
    ### Figure out which are stale files ###
    # Log beginning of index process
    puts @log.info "Begin indexing all projects"
    
    # Variables to store what will need processing after running through the index
    component = []
    project = []
    file = []
    
    # Walk through project assets
    Dir.chdir @settings['accountRoot'] do
      
      # Walk through all projects
      Dir.glob("**/*").each do |f|
        # Set the absolute path
        f = File.absolute_path f
        
        # Refresh @index
        @index.refresh
        
        # Make sure this is a valid file type,
        # is not in the /Screens directory, and
        # has changed since the last index
        if @settings['fileTypes'].include?((File.extname f).downcase) and \
          not File.dirname(f).end_with?('Screens') and \
          @index.updated? f
          
          # Capture this if it's a component
          if File.dirname(f) == @settings['componentsProject']
            # Add the file to the component list
            component.push File.absolute_path(f)
            
          # Capture this if it's a project asset
          elsif File.dirname(f).end_with?('assets')
            # Add the project to the project list
            path = f
            path.slice! @settings['accountRoot'] + '/'
            path = path.split('/')[0]
        
            # Find just the first directory in the path, this is the project dir
            project.push File.join(@settings['accountRoot'], path)
            
          # Check for individual files
          elsif not File.dirname(f) == @settings['componentsProject'] and \
            not File.dirname(f).end_with?('assets') and (\
            File.extname f).downcase == ".bmml"
            
            # include the file
            file.push File.absolute_path(f)
          end
        end
      end
    end
    
    # Cleanup the duplicates (if any)
    component.uniq!
    project.uniq!
    file.uniq!
    
    
    ### Export stale files ###
    # If a component is updated, export everything
    unless component.empty?
      @export.all
    
    # If we aren't exporting everything, export what we found
    else
      # If a project is updated, export each project first
      unless project.empty?
        project.each do |p|
          @export.project p
        end
      end
      
      # Export individual files remaining
      unless file.empty?
        file.each do |n|
          # Make sure we haven't already updated this file with a project export
          if @index.updated? n
            # Export the individual file
            @export.file n
          end
        end
      end
    end
    
    # Log end of index process
    puts @log.info "Done indexing all projects"
  end
end
