require 'pathname'
require 'fileutils'
require 'json'
require 'digest'
require './app/log.rb'
require './app/settings.rb'


# Manipulates MD5 indexes of files

class Index
  # Initialize variables needed
  def initialize
    # Instantiate settings
    s = Settings.new
    @settings = s.get
    
    # Instantiate @log class to log events
    @log = LogInfo.new @settings['indexLog']
    
    # Make sure the ./data directory exists
    unless Dir.exist?("data")
      Dir.mkdir("data")
    end
    
    # Make sure the index file exists
    unless File.exist?(@settings['indexFile'])
      cmd = `touch #{@settings['indexFile']}`
    end
    
    # Load the existing index file
    refresh
  end
  
  
  # Refresh loaded content
  def refresh
    # Load the existing index file
    @index = File.open(@settings['indexFile'], 'r'){|f| JSON.load(f)} || {}
  end
  
  
  # Save @index out to disk
  def save
    File.open(@settings['indexFile'], 'w'){|f| f.puts(@index.to_json)}
  end
  
  
  # Check if this file has been updated since
  def updated?(file)
    # Start by assuming this is an updated or new file
    updated = true
    
    # See if the file exists already
    if @index[file]
      # Nothing new for this file
      if @index[file] == getMD5(file)
        updated = false
      end
    end
    
    # Commented out, because this gets hit quite frequently and doesn't add much value any longer
    # Log that the file is found stale
    # if updated
    #   @log.info "`#{file}` is stale"
    # end
    
    # return update status
    updated
  end
  
  
  # Update the hash in the index for this file
  def update(file)
    # Update the index for this file
    @index[file] = getMD5 file
    
    # Log the new hash for the file
    @log.info "`#{file}` hash updated to #{@index[file]}"
    
    # save the index out to disk
    save
  end
  
  
  # Get the index of the file
  def getMD5(file)
    # Get the MD5 hash by reading blocks, so we don't need to open the file in memory
    md5 = Digest::MD5.file(file).hexdigest
    
    # return the hash
    md5
  end
end
