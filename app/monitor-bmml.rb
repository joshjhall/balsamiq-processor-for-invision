#!usr/bin/ruby

require 'redis'
require 'sidekiq'
require_relative 'md5'
require_relative 'log'
require_relative 'settings'
require_relative 'export-worker'


# Class to monitor BMML
class MonitorBMML
  # Initialize variables needed
  def initialize
    # Instantiate settings
    @settings = Settings.new.get
    
    # Instantiate @log class to log events
    @log = LogInfo.new @settings['monitorLog']
    
    # Open redis connection
    @redis = Redis.new(:host => @settings['redisURI'], :port => @settings['redisPort'], :db => @settings['redisDB'])
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
        # unless Dir.exist?(File.join(f, "Assets", "PM Requirements"))
        #   Dir.mkdir(File.join(f, "Assets", "PM Requirements"))
        # end
        
        # Create /Engineering Designs if missing
        # unless Dir.exist?(File.join(f, "Assets", "Engineering Designs"))
        #   Dir.mkdir(File.join(f, "Assets", "Engineering Designs"))
        # end
      end
    end
  end
  
  
  # Scan for new and changed files.  These will be added to the working queue
  def scan
    # Change to the root directory
    Dir.chdir @settings['accountRoot'] do
      
      # Create missing diretories in assets
      createDirs
      
      # Walk through current directory completely
      Dir.glob("**/*").each do |f|
        # Only check the correct file types
        if @settings['fileTypes'].include?((File.extname f).downcase)
          # Always expand the path before sending to the queue
          f = File.expand_path(f)
          
          # Only look in the ../Wireframes directory
          if File.dirname(f).match(/\/Assets\/Wireframes/)
            
            # Get the current file info
            current = @redis.get f.downcase
            
            # Start by checking if the MD5 of the file has changed
            unless current and current == getMD5(f)
              # If component changed or was added
              if File.dirname(f) == @settings['componentsProject']
                puts @log.info "Exporting all projects"
                
                # TODO add support for deleted components
                # Walk through all projects
                Dir.glob("**/*.bmml").each do |r|
                  # Reset all bmml for output, and load them in the low priority backlog
                  @redis.set r.downcase, 'stale'
                  ExportSlow.perform_async r
                end
                
              # TODO add support for deleted assets
              # If an asset is changed
              elsif File.dirname(f).end_with? 'assets'
                # Get the project name out of the directory structure
                projectName = File.dirname(f).chomp '/Assets/Wireframes/assets'
                projectName = projectName.slice(@settings['accountRoot'].length + 1, projectName.length)
                puts @log.info "Exporting project `#{projectName}`"
                
                # Walk through only this project
                Dir.glob("#{File.dirname(f).chomp '/assets'}/**/*.bmml").each do |r|
                  # Reset all bmml for output, and load them in the low priority backlog
                  @redis.set r.downcase, 'stale'
                  ExportNow.perform_async r
                end
                
              # Just reset and output this file
              elsif current and current != 'stale'
                puts @log.info "Exporting file `#{File.basename f}"
                
                # Mark the current file stale
                @redis.set f.downcase, 'stale'
                ExportNow.perform_async f
              end
            end
          end
        end
      end
    end
    
    # Close the redis connection cleanly
    @redis.quit
  end
end