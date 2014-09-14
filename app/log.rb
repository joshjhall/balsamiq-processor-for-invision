require 'fileutils'

# Simple logging class to keep things organized and ensure files are written and closed quickly

class LogInfo
  # Initialize variables needed
  def initialize file = nil
    # Set the log file during initialization
    if file
      # Make sure the file exists, so we don't have issues getting a complete path
      unless File.exist?(file)
        cmd = `touch #{file}`
      end
      
      # Get the complete path, so it doesn't matter if we change working directories later
      @logFile = File.realpath file
    end
  end
  
  
  # Print the info log entry to both the console and the log file
  def info entry
    # Set the final string for the log
    entry = "[" + Time.now.strftime("%Y-%m-%d %H:%M:%S:%L %Z") + "] " + entry
    
    if @logFile
      # Put in the log file, and ensure the file is closed immediately
      File.open(@logFile, 'a') do |f|
        f.puts entry
      end
    end
    
    # Return entry so it can be pushed to the console if needed
    entry
  end
end