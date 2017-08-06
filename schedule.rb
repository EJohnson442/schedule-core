require 'date'
require 'logger'

class Monthly_Schedule
    include Schedule_helper

    attr_accessor :rerun_max
    attr_reader :schedule
    def initialize(prep_schedule, year, month, schedule_days = [])
        @prep_schedule = prep_schedule
        @positions = prep_schedule::POSITIONS
        @year = year
        @month = month
        @schedule_days = schedule_days
    end

    def make_schedule()
        rerun = false
        rerun_count = 0
        begin
            calendar = reset_calendar(rerun)
            Attendant.data_reset() if rerun
            @schedule.each {|schedule_day| new_schedule(schedule_day,calendar)}
            Logs.debug("schedule = #{@schedule.inspect}")
            break if rerun_max <= rerun_count += 1
            rerun = Attendant.scheduled.count_candidates("unresolved")
        end while rerun
        #Logs.debug("Attendant.optimized_schedule = #{Attendant.optimized_schedule}")
        @schedule = Attendant.to_calendar(@calendar, @positions.length)
        #p @positions.length
        #Logs.debug("@calendar = #{@calendar}")
        #exit
    end

    protected
    def new_schedule(schedule_day,calendar)
        schedule_day << calendar.shift
        @positions.each do |schedule_type|
            attendant = select_attendant(schedule_type, schedule_day)
            schedule_day << schedule_type.id2name[3..schedule_type.id2name.length] + " = " + attendant
            Logs.debug("SCHEDULE_DAY = #{schedule_day}")
            schedule_day
        end
    end

    def select_attendant(schedule_type, schedule_day)
        cur_attendant = ''
        @attendant_classes.data.each do |data|
            if data.schedule_type == schedule_type  # Get attendant from appropriate list
                if data.respond_to?('custom_attendant')
                    cur_attendant = data.custom_attendant(schedule_day)
                else
                    cur_attendant = data.get_attendant()
                end
                break
            end
        end
        cur_attendant
    end

    def reset_calendar(rerun)
        @attendant_classes = @prep_schedule::Attendant_data_classes.new(@positions)
        if !defined?(@calendar)
            @calendar = gen_calendar(@year,@month,@schedule_days) {|y,m,d| Date::ABBR_DAYNAMES[Date.new(y,m,d).wday] + " " + d.to_s}
        end    
        @schedule = Array.new(@calendar.length){|i| i = []}
        @calendar.clone
    end
end