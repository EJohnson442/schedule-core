require 'date'
require 'logger'
require_relative 'utils'

module Schedule_maker
    extend self

    attr_reader :schedule_data, :assignments, :config

    class Monthly_Schedule
        include Calendar_formats

        attr_reader :schedule

        def initialize(prep_schedule, config)
            @prep_schedule = prep_schedule
            @config = config
            @daily_task_list = @config.config_data['daily_task_list'].map(&:to_sym);
            Worker.max_monthly_assignments = @config.config_data['max_monthly_assignments']
            Worker.total_tasks = @daily_task_list.count
            Worker.max_times_assigned_to_task = @config.config_data['max_times_assigned_to_task']
            Worker.scheduled_days = @config.config_data['scheduled_days'].count
            Worker.priority_schedule_types = @config.config_data['priority_schedule_types']
            @run_tests = @config.config_data['run_tests']
            make_schedule(@config.config_data['rerun_max'])
        end

        def generate_calendar(calendar_run)
            begin
                calendar_data = CALENDAR_DATA.new(calendar_run, initialize_calendar(false), @daily_task_list, Worker.scheduled)
                calendar(calendar_data)
            rescue => e
                puts e.message
            end
        end

        protected
            def make_schedule(rerun_max)
                rerun = false
                rerun_count = 0
                calendar = []
                begin
                    calendar = initialize_calendar()
                    Worker.data_reset() if rerun
                    calendar.each{|day| @daily_task_list.each { |schedule_type| select_worker(schedule_type, day) }}
                    break if rerun_max < rerun_count += 1
                    rerun = Worker.scheduled.count_candidates(Worker::DEFAULT_WORKER) > 0
                    info_make_schedule(Worker.scheduled.count_candidates(Worker::DEFAULT_WORKER), rerun_count, rerun_max, Worker.scheduled.count_candidates(Worker::DEFAULT_WORKER) > 0) if @run_tests
                end while rerun
            end

            def select_worker(schedule_type, day)
                @schedule_classes.data.each do |data|
                    if data.schedule_type == schedule_type
                        if data.respond_to?('get_custom_worker')
                            custom_data = Config::get_custom_data(data)
                            data.get_custom_worker(day, custom_data)
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