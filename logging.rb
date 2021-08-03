require 'logger'

# Levels: DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
Logs = Logger.new(STDOUT)
Logs.datetime_format = '%Y-%m-%d %H:%M:%S'

def is_valid_log(method_name, *args)
    #(__method__, candidate, is_valid, !monthly_assignments_exceeded?(), !times_assigned_to_task_exceeded?(), schedule_type)
    Logs.debug("Method name: #{method_name}")
    Logs.debug("schedule type = #{args[4]} / candidate = #{args[0]} / is valid = #{args[1]}")
    Logs.debug("monthly assignments exceeded = #{args[2]} / times assigned to task exceeded = #{args[3]}")
end

def get_custom_worker_log(method_name, *args)
    Logs.debug("Method name: #{method_name}")
    Logs.debug("args: #{args[0]}")
    Logs.debug("schedule_type: #{args[1]}")
    Logs.debug("worker: #{args[2]}")
end

def candidate_in_prior_weeks_log(method_name, *args)
    Logs.debug("Method name: #{method_name}")
    Logs.debug("Range: #{args[0]} to #{args[1]} & tasks per week: #{args[2]} & data length: #{args[3]}")
    Logs.debug("")
end

def info_make_schedule(count_candidates, rerun_count, rerun_max, count_candidates_gt0)
    Logs.debug("***** make_schedule")
    Logs.debug("rerun count: #{rerun_count}")
    Logs.debug("rerun max: #{rerun_max}")
    Logs.debug("DEFAULT_WORKER count: #{count_candidates}")
    Logs.debug("count candidates: #{count_candidates_gt0}")
    Logs.debug("")
end

def info_recently_assigned_log(candidate, scheduled,workers,date_range,recently_assigned)
    Logs.debug("***** recently_assigned")
    Logs.debug("candidate: #{candidate}")
    Logs.debug("scheduled: #{scheduled}")
    Logs.debug("workers: #{workers}")
    Logs.debug("range: #{date_range}")
    Logs.debug("recently_assigned: #{recently_assigned}")
    Logs.debug("")
end

def exception_msg(method, msg)
    Logs.error("Method name: #{method}")
    Logs.error("ERROR: '#{msg}")
    Logs.error("")
end

