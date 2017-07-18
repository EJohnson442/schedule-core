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
        @unresolved = 0
        logger()
    end

    def make_schedule()
        rerun = false
        rerun_count = 0
        begin
            calendar = reset_calendar()
            Attendant.data_reset() if rerun
            @schedule.each {|schedule_day| new_schedule(schedule_day,calendar)}
            @logger.debug("schedule = #{@schedule.inspect}")
            break if rerun_max <= rerun_count += 1
            rerun = Attendant.scheduled.count_candidates("unresolved")
            optimize_data() if rerun || @tmp_Attendant != nil
        end while rerun
        @schedule = @tmp_schedule if @tmp_schedule != nil
    end

    #keep data with fewest occurances of "unresolved" & position of "unresolved" nearest month's end
    def optimize_data()
        if @tmp_Attendant == nil
            @tmp_Attendant = Attendant.scheduled()
            @tmp_schedule = @schedule
        elsif @tmp_Attendant.count_candidates("unresolved") >= Attendant.scheduled.count_candidates("unresolved") && @tmp_Attendant.position_of("unresolved") < Attendant.scheduled.position_of("unresolved")
                @tmp_Attendant = Attendant.scheduled()
                @tmp_schedule = @schedule
        end
    end

    protected
    def new_schedule(schedule_day,calendar)
        #update schedule date here
        schedule_day << calendar.shift
        @positions.each do |schedule_type|
            attendant = select_attendant(schedule_type, schedule_day)
            schedule_day << schedule_type.id2name[3..schedule_type.id2name.length] + " = " + attendant
        end
    end

    def select_attendant(schedule_type, schedule_day)
        cur_attendant = ''
        @schedule_data.data.each do |data|
            if data.schedule_type == schedule_type  # Get attendant from appropriate list
                data.schedule_day = schedule_day
                if data.respond_to?('select_attendant')
                    cur_attendant = data.select_attendant(@schedule.index(schedule_day).even?)  #What is this parameter about?????
                else
                    cur_attendant = data.get_attendant()
                end
                break
            end
        end
        cur_attendant
    end

    def reset_calendar()
        @schedule_data = @prep_schedule::Attendant_data_classes.new(@positions)
        calendar = gen_calendar(@year,@month,@schedule_days) {|y,m,d| Date::ABBR_DAYNAMES[Date.new(y,m,d).wday] + " " + d.to_s}
        @schedule = Array.new(calendar.length){|i| i = []}
        calendar
    end
    
    def logger()
        @logger = Logger.new(STDOUT, progname: 'fishy')
        @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
        @logger.level = Logger::DEBUG
    end
end