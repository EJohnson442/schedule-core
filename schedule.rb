require 'date'
require 'logger'
require_relative 'utils'

module Schedule_maker
    extend self

    SCHEDULE_DATA = Struct.new(:positions, :rerun_max, :scheduled_days, :consecutive_days, :year, :month, :monthly_assignments, :max_assigned_to_task)
    attr_reader :schedule_data, :assignments

    class Monthly_Schedule
        include Calendar_formats

        attr_reader :schedule

        def initialize(prep_schedule, config)
            @prep_schedule = prep_schedule
            @config = config
            Attendant.monthly_assignments = @config.monthly_assignments
            Attendant.total_positions = @config.positions.count
            Attendant.max_assigned_to_task = @config.max_assigned_to_task
            make_schedule(@config.rerun_max)
        end

        def generate_calendar(calendar_run)
            begin
                calendar_data = CALENDAR_DATA.new(calendar_run, initialize_calendar(false), @config.positions, Attendant.scheduled, Attendant.scheduled)
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
                    Attendant.data_reset() if rerun
                    calendar.each{|day| @config.positions.each { |schedule_type| select_attendant(schedule_type, day) }}
                    break if rerun_max <= rerun_count += 1
                    rerun = Attendant.scheduled.count_candidates(Attendant::DEFAULT_ATTENDANT)
                end while rerun
            end

            def select_attendant(schedule_type, day)
                @attendant_classes.data.each do |data|
                    if data.schedule_type == schedule_type
                        if data.respond_to?('get_custom_attendant')
                            data.consecutive_days = @config.consecutive_days[schedule_type.to_s]
                            data.get_custom_attendant(day)
                        else
                            data.get_attendant()
                        end
                        break
                    end
                end
            end

            def gen_calendar(year, month, days_of_week = [])
                calendar = []
                day = 0
                until !Date.valid_date?(year,month,day += 1)
                    if days_of_week.include?(Date.new(year,month,day).cwday) || days_of_week == []
                        block_given? ? calendar << yield(year,month,day) : calendar << day.to_s
                    end
                end
                calendar
            end

            def initialize_calendar(prep_schedule = true)
                @attendant_classes = @prep_schedule::Attendant_data_classes.new(@config.positions) if prep_schedule
                gen_calendar(@config.year,@config.month,@config.scheduled_days) {|y,m,d| Date::ABBR_DAYNAMES[Date.new(y,m,d).wday] + " " + d.to_s}
            end
    end
end