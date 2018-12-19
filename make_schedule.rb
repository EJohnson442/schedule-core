$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << 'work'
require_relative 'init_workers'
require_relative 'scheduler'
require_relative 'config'
#require_relative 'utils'

module Make_schedule
    extend self

    include Config
    include Scheduler
    include Calendar_formats

    def generate(calendar = :task, month = Time.now.month, year = Time.now.year)
        Config::month = month
        Config::year = year

        ms = Monthly_Schedule.new(Init_workers, Config)
        ms.generate_calendar(calendar)
    end
end

p Make_schedule.generate()
