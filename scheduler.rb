$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << 'attendants'
require_relative 'setup'
require_relative 'schedule'
require_relative 'config'
require_relative 'utils'

module Schedules
    extend self

    include Config
    include Schedule_maker
    include Calendar_formats

    def generate(calendar = :task, month = Time.now.month, year = Time.now.year)
        Config::month = month
        Config::year = year

        ms = Monthly_Schedule.new(Prep_schedule, Config)
        ms.generate_calendar(calendar)
    end
end

p Schedules.generate()