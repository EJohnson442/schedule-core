require_relative 'schedule';


Schedule.randomize_count = 23
#This value should be calculated as follows:  weeks - 1 or sun > wed ? sun - 1 : wed - 1
Schedule.monthly_assignments = 4
Schedule.weekly_assignments = positions.count
#Schedule.weekly_assignments = 10
ms = Monthly_Schedule.new(schedule_data, positions, 2016, 3)
ms.sound_position = :ST_SOUND
ms.rerun_max = 5
ms.make_schedule()
#puts "scheduled = #{Schedule.scheduled()}"
puts ""
puts "details = #{Schedule.scheduled}"
puts ""