require 'date'
require 'logger'

class Monthly_Schedule
    include Schedule_helper

    attr_reader :schedule
    def initialize(prep_schedule, positions, rerun_max, schedule_days, year, month)
        @prep_schedule = prep_schedule  #ACT - prep_schedule is a terrible name!!!!! Find a more descriptive name.
        @positions = positions
        @year = year
        @month = month
        @schedule_days = schedule_days
        make_schedule(rerun_max)
    end

    def make_schedule(rerun_max)
        rerun = false
        rerun_count = 0
        calendar = []
        begin
            calendar = reset_calendar()
            Attendant.data_reset() if rerun
            calendar.each do |day|
                @positions.each { |schedule_type| select_attendant(schedule_type, day) }
            end
            break if rerun_max <= rerun_count += 1
            rerun = Attendant.scheduled.count_candidates(Attendant::DEFAULT_ATTENDANT)
        end while rerun
        @schedule = Attendant.to_calendar(calendar, @positions.length)
    end

    protected
        def select_attendant(schedule_type, day)
            @attendant_classes.data.each do |data|
                if data.schedule_type == schedule_type      #Get attendant from appropriate list
                    if data.respond_to?('get_custom_attendant')
                        data.get_custom_attendant(day)      #QRY - Why isn't the parameter day needed in both here and get_attendant?????
                    else
                        data.get_attendant()
                    end
                    break
                end
            end
        end

        def reset_calendar()
            @attendant_classes = @prep_schedule::Attendant_data_classes.new(@positions)
            gen_calendar(@year,@month,@schedule_days) {|y,m,d| Date::ABBR_DAYNAMES[Date.new(y,m,d).wday] + " " + d.to_s}
        end
end