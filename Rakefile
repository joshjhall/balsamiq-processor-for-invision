#!usr/bin/ruby

require_relative 'app/log'
require_relative 'app/monitor-bmml'


# Default task definition
task :default => :scan


# Run scan task
task :scan do
  m = MonitorBMML.new
  m.scan
end
