#!usr/bin/ruby

require 'redis'
require 'sidekiq'
require_relative 'md5'
require_relative 'log'
require_relative 'settings'


# Start command "sidekiq -r ./app/export-worker.rb -C ./config/sidekiq.yml"

# If your client is single-threaded, we just need a single connection in our Redis connection pool
Sidekiq.configure_client do |config|
  config.redis = { :namespace => Settings.new.get['workerNamespace'], :size => 1 }
end


# Sidekiq server is multi-threaded so our Redis connection pool size defaults to concurrency (-c)
Sidekiq.configure_server do |config|
  config.redis = { :namespace => Settings.new.get['workerNamespace'] }
end


module ExportWorker
  # Get the PNG related to a BMML file
  def screenName f
    # Define the output file based on the input
    # 1. Move to screens directory
    # 2. Change extension from bmml to png
    # 3. Remove any sub-directories under Screens, because InVision will ignore them
    output = f.gsub(/\/Assets\/Wireframes\//, '/Screens/').gsub(/\.bmml/, '.png').gsub(/\/Screens\/.*\/([^\/]*\.png)/, '/Screens/\1')
    
    output
  end
  
  
  # Safely export the file to PNG
  def export f
    settings = Settings.new.get
    log = LogInfo.new settings['workerLog']
    redis = Redis.new(:host => settings['redisURI'], :port => settings['redisPort'], :db => settings['redisDB'])
    
    # Make sure the file still exists before processing
    if File.exists? f
      # Get the current file info
      current = redis.get f.downcase
      
      # See if the file is still stale or missing
      if (current and current == 'stale') or current == nil
        # If BMML and not an asset, then process the file export
        if File.extname(f) == '.bmml' and not File.dirname(f).end_with? 'assets'
          # Log what is about to be processed
          log.info "Starting file `#{File.basename(f)}`"
        
          # Join elements for the final output component of the command
          cmd = "#{Shellwords.escape(settings['balsamiqBin'])} export #{Shellwords.escape(f)} #{Shellwords.escape(screenName(f))}"
        
          # Run the export using the Balsamiq desktop client
          result = `#{cmd}`
        end
        
        # Update the md5 and status for this record
        log.info "Updating MD5 for `#{File.basename(f)}`"
        redis.set f.downcase, getMD5(f.downcase)
      
      # Bypass this file, because it's no longer stale
      else
        # log.info "Bypassing attempt on `#{File.basename(f)}`"
      end
      
    # Delete the key for the file that no longer exists
    else
      log.info "Deleting key for `#{File.basename(f)}`"
      redis.del f.downcase
    end
    
    redis.quit
  end
end


class ExportSlow
  include Sidekiq::Worker
  sidekiq_options :queue => :slow
  
  # Include the worker module
  include ExportWorker
  
  # Perform work
  def perform f
    # Export the file
    export f
  end
end


class ExportNow
  include Sidekiq::Worker
  sidekiq_options :queue => :default
  
  # Include the worker module
  include ExportWorker
  
  # Perform work
  def perform f
    # Export the file
    export f
  end
end
