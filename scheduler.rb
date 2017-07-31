$LOAD_PATH << 'attendants'
require_relative 'utils'
require_relative 'setup'
require_relative 'schedule'
require 'attendant.rb'

#This value should be calculated as follows:  weeks - 1 or sun > wed ? sun - 1 : wed - 1
Attendant.monthly_assignments = 4   #config value
Attendant.weekly_assignments = Prep_schedule::POSITIONS.count
ms = Monthly_Schedule.new(Prep_schedule, 2017, 7, [Schedule_helper::SUN,Schedule_helper::WED]) 
ms.rerun_max = 5                    #config value
ms.make_schedule()

#********** TEST CODE **********
include Schedule_helper     #Utils.rb
showdata(ms.schedule)

#puts ""
#puts "details = #{Attendant.scheduled}"
#puts ""
