#!usr/bin/ruby

require_relative 'app/log'
require_relative 'app/monitor-bmml'


# Default task definition
task :default => :scan

# Run scan continuously
task :continuous do
  m = MonitorBMML.new
  
  puts 'Continuous scanner started.'
  puts ''
  
  # Loop and check for updates every few seconds
  loop do
    sleep 10
    break unless m.scan
  end
end

# Run scan once
task :scan do
  m = MonitorBMML.new
  m.scan
end

# Start redis server
task :redis do
  cmd = 'redis-server ./config/redis.conf'
  exec cmd
end

# Start sidekiq server
task :sidekiq do
  cmd = 'sidekiq -r ./app/export-worker.rb -C ./config/sidekiq.yml'
  exec cmd
end
