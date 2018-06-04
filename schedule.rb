require 'date'
require 'logger'

module Schedule_maker
    extend self

    @schedule_data = Struct.new(:prep_schedule, :positions, :rerun_max, :schedule_days, :year, :month, :monthly_assignments, :max_assigned_to_task)
    attr_reader :schedule_data, :assignments

    class Monthly_Schedule
        include Schedule_helper

        attr_reader :schedule
        def initialize(schedule_data)
            @schedule_data = schedule_data
            Attendant.monthly_assignments = @schedule_data.monthly_assignments
            Attendant.weekly_assignments = @schedule_data.positions.count
            Attendant.max_assigned_to_task = @schedule_data.max_assigned_to_task
            make_schedule(@schedule_data.rerun_max)
        end

        def make_schedule(rerun_max)
            rerun = false
            rerun_count = 0
            calendar = []
            begin
                calendar = reset_calendar()
                Attendant.data_reset() if rerun
                calendar.each{|day| @schedule_data.positions.each { |schedule_type| select_attendant(schedule_type, day) }}
                break if rerun_max <= rerun_count += 1
                rerun = Attendant.scheduled.count_candidates(Attendant::DEFAULT_ATTENDANT)
            end while rerun
            @assignments = Attendant.scheduled
            @schedule = Attendant.to_calendar(calendar, @schedule_data.positions.length)
        end

        protected
            def select_attendant(schedule_type, day)
                @attendant_classes.data.each do |data|
                    if data.schedule_type == schedule_type      #Get attendant from appropriate list
                        data.respond_to?('get_custom_attendant') ? data.get_custom_attendant(day) : data.get_attendant()
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

            def reset_calendar()
                @attendant_classes = @schedule_data.prep_schedule::Attendant_data_classes.new(@schedule_data.positions)
                gen_calendar(@schedule_data.year,@schedule_data.month,@schedule_data.schedule_days) {|y,m,d| Date::ABBR_DAYNAMES[Date.new(y,m,d).wday] + " " + d.to_s}
            end
    end
end