require 'logger'

# Levels: DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
Logs = Logger.new(STDOUT)
Logs.datetime_format = '%Y-%m-%d %H:%M:%S'

def info_make_schedule(count_candidates, rerun_count, rerun_max, count_candidates_gt0)
    Logs.info("***** make_schedule")
    Logs.info("rerun count: #{rerun_count}")
    Logs.info("rerun max: #{rerun_max}")
    Logs.info("DEFAULT_WORKER count: #{count_candidates}")
    Logs.info("count candidates: #{count_candidates_gt0}")
    Logs.info("")
end

def info_workers(schedule_type, workers)
    Logs.info("***** Initialize")
    Logs.info("schedule_type = #{schedule_type}")
    Logs.info("workers = #{workers}")
    Logs.info("")
end

def info_create_schedule_classes(task)
    Logs.info("***** create_attendant_classes")
    Logs.info(task)
    Logs.info("")
end