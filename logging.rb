require 'logger'

# Levels: DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
Logs = Logger.new(STDOUT)
Logs.datetime_format = '%Y-%m-%d %H:%M:%S'