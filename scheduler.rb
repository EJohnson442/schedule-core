$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << 'work'
require_relative 'load_data_files'
require_relative 'schedule'
require_relative 'config'
require_relative 'utils'

module Scheduler
    extend self

    include Config
    include Schedule_maker
    include Calendar_formats

    def generate(calendar = :task, month = Time.now.month, year = Time.now.year)
        if Config::config_data == nil
            Config::load_config(File.open('config.yml'))
        end    
        Config::config_data['month'] = month
        Config::config_data['year'] = year

        ms = Monthly_Schedule.new(Prep_schedule, Config)
        ms.generate_calendar(calendar)
    end
end

p Scheduler.generate()