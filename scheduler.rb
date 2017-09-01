$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << 'attendants'
require_relative 'utils'
require_relative 'setup'
require_relative 'schedule'
require_relative 'config'
require 'attendant'

#config = Config.load('./data/config.yml')
include Config
#p Config.positions
#exit
#This value should be calculated as follows:  weeks - 1 or sun > wed ? sun - 1 : wed - 1
Attendant.monthly_assignments = Config.monthly_assignments       #config value
Attendant.weekly_assignments = Config.positions.count
Attendant.max_assigned_to_task = Config.max_assigned_to_task
ms = Monthly_Schedule.new(Prep_schedule, Config.year, Config.month, Config.positions.map(&:to_sym), Config.rerun_max, Config.scheduled_days) 

#********** TEST CODE **********
include Schedule_helper     #Utils.rb
showdata(ms.schedule)

puts ""
puts "details = #{Attendant.scheduled}"
puts ""
