require 'rubygems'
require './app/listener.rb'
require './app/scanner.rb'


# Default task definition
task :default => :listen


# Execute the export task
task :listen do
  # Start the listener
  l = Listener.new
end


task :scan do
  # Check if anything needs to be processed
  s = Scanner.new
  
  s.all
end
