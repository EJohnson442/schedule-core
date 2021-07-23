require 'logger'

# Levels: DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
Logs = Logger.new(STDOUT)
Logs.datetime_format = '%Y-%m-%d %H:%M:%S'

def is_valid_log(method_name, *args)
    Logs.debug("Method name: #{method_name}")
    Logs.debug("new_assignments = #{args[0]}")
    Logs.debug("assignments = #{args.count[1]}")
    Logs.debug("max_monthly_assignments = #{args.count[2]}")
    Logs.debug("valid = #{args.count[3]}")
end

def get_custom_worker_log(method_name, *args)
    Logs.debug("Method name: #{method_name}")
    Logs.debug("args: #{args[0]}")
    Logs.debug("schedule_type: #{args[1]}")
    Logs.debug("worker: #{args[2]}")
end

def if_recently_assigned_log(method_name, *args)
    Logs.debug("Method name: #{method_name}")
    Logs.debug("is_valid => recently_assigned: #{args[0]}")
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

def error_load_config(method, msg)
    Logs.error("Method name: #{method}")
    Logs.error("load_config error - '#{msg}")
    Logs.error("")
end