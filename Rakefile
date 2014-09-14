require 'rubygems'
require './app/listener.rb'


# Default task definition
task :default => :export


# Execute the export task
task :export do
  # Start the listener
  l = Listener.new
end

# Update / install gems
task :update do
  puts `bundle update`
end
