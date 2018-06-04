$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << 'attendants'
require_relative 'setup'
require_relative 'schedule'
require_relative 'config'
require_relative 'utils'

include Config
include Schedule_maker
include Calendar_formats

schedule_data = Schedule_maker.schedule_data.new(Prep_schedule, Config.positions, Config.rerun_max, Config.scheduled_days, Config.year, Config.month, Config.monthly_assignments, Config.max_assigned_to_task)
ms = Monthly_Schedule.new(schedule_data)
rc = ms.generate_calendar()
Calendar_formats::task_view_calendar(rc)