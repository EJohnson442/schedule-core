$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << 'attendants'
require_relative 'utils'
require_relative 'setup'
require_relative 'schedule'
require_relative 'config'
require 'attendant'

include Config
include Schedule_maker
Attendant.monthly_assignments = Config.monthly_assignments
Attendant.weekly_assignments = Config.positions.count
Attendant.max_assigned_to_task = Config.max_assigned_to_task
schedule_data = Schedule_maker.schedule_data.new(Prep_schedule, Config.positions, Config.rerun_max, Config.scheduled_days, Config.year, Config.month)
ms = Monthly_Schedule.new(schedule_data) 

#********** TEST CODE **********
include Schedule_helper     #Utils.rb
showdata(ms.schedule)

puts ""
puts "details = #{Attendant.scheduled}"
puts ""
 