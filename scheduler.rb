$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << 'attendants'
require_relative 'setup'
require_relative 'schedule'
require_relative 'config'
require_relative 'utils'

include Config
include Schedule_maker
include Calendar_formats

#Run scheduler using config.yml
#Replace Config with Scheduler::SCHEDULE_DATA struct to dynamically create schedules
ms = Monthly_Schedule.new(Prep_schedule, Config)

#p ms.generate_calendar(:json)
ms.generate_calendar(:task)
