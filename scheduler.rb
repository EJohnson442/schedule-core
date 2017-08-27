$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << 'attendants'
require_relative 'utils'
require_relative 'setup'
require_relative 'schedule'
require_relative 'config'
require 'attendant'

config = Config.load('./data/config.yml')
#This value should be calculated as follows:  weeks - 1 or sun > wed ? sun - 1 : wed - 1
Attendant.monthly_assignments = config['monthly_assignments']       #config value
Attendant.weekly_assignments = Prep_schedule::POSITIONS.count
Attendant.max_assigned_to_task = config['max_assigned_to_task']
ms = Monthly_Schedule.new(Prep_schedule, config['year'], config['month'], [Schedule_helper::SUN,Schedule_helper::WED], config['rerun_max']) 

#********** TEST CODE **********
include Schedule_helper     #Utils.rb
showdata(ms.schedule)

#puts ""
#puts "details = #{Attendant.scheduled}"
#puts ""
