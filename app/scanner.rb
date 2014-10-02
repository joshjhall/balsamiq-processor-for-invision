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
  
  
  # Get the file context
  def fileContext(f, input)
    out = {}
    
    # Capture this if it's a component
    if File.dirname(f) == @settings['componentsProject'] or \
      File.dirname(f) == File.absolute_path(@settings['componentsProject'])
      
      out[:component] = File.absolute_path(f)
      
    # Capture this if it's a project asset
    elsif File.dirname(f).end_with?('assets')
      # Add the project to the project list
      path = f
      path = path.slice(Shellwords.escape(@settings['accountRoot'] + '/'))
      path = path.split('/')[0]
      
      # Find just the first directory in the path, this is the project dir
      out[:project] = Shellwords.escape(File.join(@settings['accountRoot'], path))
      
    # Check for individual files
    elsif not File.dirname(f) == @settings['componentsProject'] and \
      not File.dirname(f).end_with?('assets')
      
      # Include the file
      out[:file] = File.absolute_path(f)
    end
    
    # Capture this if it's a component
    if out[:component]
      input[:component].push out[:component]
      
    # Capture this if it's a project asset
    elsif out[:project]
      input[:project].push out[:project]
      
    # Check for individual files
    elsif out[:file]
      if (File.extname out[:file]).downcase == ".bmml"
        input[:file].push out[:file]
      end
    end
    
    # Return the processed input
    input
  end
  
  
  # Get all of the stale files from the current directory
  def staleFiles
    # Log beginning of stale file check
    # puts @log.info "Looking for stale files"
    
    # Variables to store what will need processing after running through the index
    stale = { :component => [], :project => [], :file => [] }
    
    # Walk through current directory completely
    Dir.glob("**/*").each do |f|
      # Set the absolute path
      f = File.absolute_path f
      
      # Make sure this is a valid file type,
      # is not in the /Screens directory, and
      # has changed since the last index
      if @settings['fileTypes'].include?((File.extname f).downcase) and \
        not File.dirname(f).end_with?('Screens') and \
        @index.updated? f
        
        # Get the file context
        stale = fileContext f, stale
      end
    end
    
    # Cleanup the duplicates (if any)
    stale[:component].uniq!
    stale[:project].uniq!
    stale[:file].uniq!
    
    # Return the finalized list of stale files
    stale
  end
  
  
  # Get all of the missing files that are in the index
  def deletedFiles
    # Log beginning of deleted file check
    # puts @log.info "Looking for deleted files"
    
    # Variable to store list of files that were deleted
    deleted = { :component => [], :project => [], :file => [] }
    
    # Get the current index to identify deleted files
    index = @index.get
    
    index.each do |f, m|
      # Only consider files that no longer exist
      unless File.exist?(f)
        # Remove the reference from the index
        @index.delete f
        
        # Get the file context
        deleted = fileContext f, deleted
      end
    end
    
    # Cleanup the duplicates (if any)
    deleted[:component].uniq!
    deleted[:project].uniq!
    deleted[:file].uniq!
    
    # Return the list of deleted files
    deleted
  end
  
  
  # Create the baseline directories for each project
  def createDirs
    # Step through only the project level directories
    Dir.glob("*").each do |f|
      # Make sure we're looking at a directory
      if File.directory? f
        # Create /Wireframes if missing
        unless Dir.exist?(File.join(f, "Assets", "Wireframes"))
          Dir.mkdir(File.join(f, "Assets", "Wireframes"))
        end
        
        # Create /Wireframes/assets if missing (skip the componentsProject)
        unless Dir.exist?(File.join(f, "Assets", "Wireframes", "assets")) or \
          @settings['componentsProject'] == File.absolute_path(File.join(f, "Assets", "Wireframes"))
          Dir.mkdir(File.join(f, "Assets", "Wireframes", "assets"))
        end
        
        # Create /PM Requirements if missing
        unless Dir.exist?(File.join(f, "Assets", "PM Requirements"))
          Dir.mkdir(File.join(f, "Assets", "PM Requirements"))
        end
        
        # Create /Engineering Designs if missing
        unless Dir.exist?(File.join(f, "Assets", "Engineering Designs"))
          Dir.mkdir(File.join(f, "Assets", "Engineering Designs"))
        end
      end
    end
  end
  
  
  # Scan all projects to update anything new
  def scan
    # Close any open tabs in Balsamiq, also ensures Balsamiq is open
    cmd = `#{@settings['closeWindows']}`
    
    ### Figure out which are stale files ###
    # Change to the root directory
    Dir.chdir @settings['accountRoot'] do
      # Get the list of stale files
      stale = staleFiles
      
      # Get the list of deleted files
      deleted = deletedFiles
      
      # Make sure newly created projects have the appropriate directories
      createDirs
      
      ### Export stale files ###
      # If a component is updated, export everything
      unless stale[:component].empty? and \
        deleted[:component].empty?
        @export.all

      # If we aren't exporting everything, export what we found
      else
        # If a project is updated, export each project first
        unless stale[:project].empty?
          stale[:project].each do |p|
            @export.project p

            # Drop any duplicates of this project in deleted
            deleted[:project].delete(p)
          end
        end

        # If a project has something deleted, export the projects again
        unless deleted[:project].empty?
          deleted[:project].each do |p|
            @export.project p
          end
        end

        # Export individual files remaining
        unless stale[:file].empty?
          stale[:file].each do |n|
            # Make sure we haven't already updated this file with a project export
            if @index.updated? n
              # Export the individual file
              @export.file n
            end
          end
        end

        # Delete the individual orphan files remaining
        unless deleted[:file].empty?
          deleted[:file].each do |n|
            @export.delete n
          end
        end
      end
    end
    
    # Close any open tabs in Balsamiq, also ensures Balsamiq is open
    cmd = `#{@settings['closeWindows']}`
  end
end
