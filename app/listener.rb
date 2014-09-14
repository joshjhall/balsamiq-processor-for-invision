require 'pathname'
require 'fileutils'
require 'listen'
require './app/log.rb'
require './app/settings.rb'
require './app/export-bmml.rb'


# Watches BMML file CRUD for InVision integration
# Will automatically trigger exports based on CRUD events

class Listener
  # Initialize variables needed
  def initialize
    # Instantiate settings
    s = Settings.new
    @settings = s.get
    
    # Instantiate @log class to log events
    @log = LogInfo.new @settings['listenerLog']
    
    # Instantiate @export to manage exports
    @export = ExportBmml.new
    
    # Start the listener
    exec
  end
  
  
  # Export files that have been created or modified
  def export(path, clean = false)
    # Only bother if this is a bmml file
    if File.extname(path) == '.bmml'
      
      # Determine if this requires exporting all projects
      if File.dirname(path) == @settings['componentsProject']
        @export.all
    
      # Determine if this requires exporting the current project
      elsif File.dirname(path).end_with?('assets')
        # Temporarily slice the account root
        path.slice! @settings['accountRoot'] + '/'
        path = path.split('/')[0]
        
        # Find just the first directory in the path, this is the project dir
        path = File.join(@settings['accountRoot'], path)
        
        # Export the project dir
        @export.project path
      
      # Just output the current file
      else
        if clean
          puts "clean only"
          @export.clean path
        else
          puts "export file"
          @export.file path
        end
      end
    end
  end
  
  
  # Listen manager
  def exec
    # Log the starting listener
    puts @log.info "Listening to #{@settings['accountRoot']}"
    
    listener = Listen.to(@settings['accountRoot']) do |modified, added, removed|
      # Log the basic input for debugging race conditions
      unless modified.empty?
        puts @log.info "  Modified: #{modified}"
      end
      unless added.empty?
        puts @log.info "  Added: #{added}"
      end
      unless removed.empty?
        puts @log.info "  Removed: #{removed}"
      end
      
      # Loop through the modified elements
      modified.each do |m|
        export m
      end
      
      # Loop through the added elements
      added.each do |a|
        export a
      end
      
      # Loop through the removed elements
      removed.each do |r|
        export r, true
      end
    end
    
    listener.start # not blocking
    sleep
  end
end
