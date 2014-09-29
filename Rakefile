require 'rubygems'
require 'pathname'
require 'fileutils'
require './app/scanner.rb'
require './app/log.rb'


# Default task definition
task :default => :scan


# Run scan task
task :scan do
  l = LogInfo.new
  lock = 'scanner.lockfile'

  # Ensure we aren't already running this process
  if Pathname(lock).exist?
    puts l.info "Lockfile `#{lock}` already exists. Skipping process."

  else
    # Lock the process, so we don't try to run a second instance
    FileUtils.touch(lock)
    
    # Run the potentially long running script
    s = Scanner.new
    s.scan
    
    # Unlock the process again
    FileUtils.rm(lock)
  end
end
