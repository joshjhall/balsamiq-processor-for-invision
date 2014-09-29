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
  
  
  # Get @index for stepping through
  def get
    # Start by making sure the index file is updated
    refresh
    
    # Return the current index list
    @index
  end
  
  
  # Delete a file reference
  def delete(f)
    # Delete the file reference
    @index.delete(f)
    
    # Save the file to disk
    save
  end
  
  
  # Save @index out to disk
  def save
    File.open(@settings['indexFile'], 'w'){|f| f.puts(@index.to_json)}
  end
  
  
  # Check if this file has been updated since
  def updated?(f)
    # Start by assuming this is an updated or new file
    updated = true
    
    # See if the file exists already
    if @index[f]
      # Nothing new for this file
      if @index[f] == getMD5(f)
        updated = false
      end
    end
    
    # return update status
    updated
  end
  
  
  # Update the hash in the index for this file
  def update(f)
    # Update the index for this file
    @index[f] = getMD5 file
    
    # Log the new hash for the file
    @log.info "`#{f}` hash updated to #{@index[f]}"
    
    # save the index out to disk
    save
  end
  
  
  # Get the index of the file
  def getMD5(f)
    # Get the MD5 hash by reading blocks, so we don't need to open the file in memory
    md5 = Digest::MD5.file(f).hexdigest
    
    # return the hash
    md5
  end
end
