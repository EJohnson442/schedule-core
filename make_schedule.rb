$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << 'work'
$LOAD_PATH << 'helpers'
require_relative 'scheduler'
require_relative 'config'

module Make_schedule
  extend self

  include Config
  include Scheduler
  include Calendar_formats

  def generate(calendar = :task, month = Time.now.month, year = Time.now.year, *config_data)
    if config_data.count == 0
      Config::load_config_file(File.open('config.yml'))
    else
      Config::config_data = config_data[0]
    end

    Config::config_data['month'] = month
    Config::config_data['year'] = year

    ms = Monthly_Schedule.new(Config)
    ms.generate_calendar(calendar)
  end
end

p Make_schedule.generate()
