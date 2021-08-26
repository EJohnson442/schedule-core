require 'date'
require 'logger'
require_relative 'calendar'

module Schedule_maker
    extend self

    class Monthly_Schedule
        include Calendar_formats

        def initialize(prep_schedule, config)
            @prep_schedule = prep_schedule
            @config = config
            @daily_task_list = @config.config_data['daily_task_list'].map(&:to_sym);
            Worker.max_monthly_assignments = @config.config_data['max_monthly_assignments']
            Worker.daily_tasks_list_count = @daily_task_list.count
            Worker.max_times_assigned_to_task = @config.config_data['max_times_assigned_to_task']
            Worker.scheduled_days_count = @config.config_data['scheduled_days'].count
            Worker.priority_schedule_types = @config.config_data['priority_schedule_types']
            Worker.preserve_priority_workers = @config.config_data['preserve_priority_workers']
            Worker.rerun_max = @config.config_data['rerun_max']
            Worker.validate_weeks = @config.config_data['validate_weeks']
            Worker.cdays_validate_weeks = @config.config_data['cdays_validate_weeks']
            @run_tests = @config.config_data['run_tests']   #this doesn't do anything and needs to be fixed
            make_schedule()
        end

        def generate_calendar(calendar_run)
            begin
                calendar_data = CALENDAR_DATA.new(calendar_run, initialize_calendar(false), @daily_task_list, Worker.schedule_data)
                calendar(calendar_data)
            rescue => e
                exception_msg(__method__, e.message)
            end
        end

        protected
        def make_schedule()
            begin
                calendar = initialize_calendar()
                rerun = !Worker.schedule_ready()
                calendar.each{|day| @daily_task_list.each { |schedule_type| select_worker(schedule_type, day) }}
            end while rerun
        end

        def select_worker(schedule_type, day)
            @schedule_classes.data.each do |data|
                if data.schedule_type == schedule_type
                    if data.respond_to?(:get_custom_worker)
                        data.get_custom_worker(day, Config::get_custom_data(data))
                    else
                        data.get_worker()
                    end
                    break
                end
            end
        end

        def gen_calendar(year, month, scheduled_days_of_week = [])
            calendar = []
            day = 0
            until !Date.valid_date?(year,month,day += 1)
                if scheduled_days_of_week.include?(Date.new(year,month,day).cwday) || scheduled_days_of_week == []
                    block_given? ? calendar << yield(year,month,day) : calendar << day.to_s
                end
            end
            calendar
        end

        def initialize_calendar(prep_schedule = true)
            @schedule_classes = @prep_schedule::Schedule_classes.new(@daily_task_list) if prep_schedule
            gen_calendar(@config.config_data['year'],@config.config_data['month'],@config.config_data['scheduled_days']) {|y,m,d| Date::ABBR_DAYNAMES[Date.new(y,m,d).wday] + " " + d.to_s}
        end
    end
end