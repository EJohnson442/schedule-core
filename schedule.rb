require 'date'
require_relative 'utils'
require 'logger'

class Monthly_Schedule
    include Schedule_helper

    attr_accessor :rerun_max
    attr_reader :schedule
    def initialize(prep_schedule, year, month)
        @prep_schedule = prep_schedule
        @positions = prep_schedule::POSITIONS
        @year = year
        @month = month
        logger()
    end
    
    def make_schedule()                                     #Cycle through appropriate calendar dates
        rerun_cnt = 0
        begin
            rerun = false
            calendar = reset_calendar()
            @schedule.each do |schedule_day|
                rerun = new_schedule(schedule_day,calendar)
                if rerun
                    rerun_cnt += 1
                    Attendant.data_reset()
                end
            end

            break if rerun_max < rerun_cnt
        end while rerun == true
        @logger.debug("rerun_cnt = #{rerun_cnt} & rerun_max = #{rerun_max} & rerun = #{rerun}")
        @logger.warn("increase rerun_max or total attendant") if rerun_cnt > rerun_max
    end

    protected
    def new_schedule(schedule_day,calendar)                 #Cycle through positions
        #update schedule date here???
        rerun = false
        schedule_day << calendar.shift
        @positions.each do |schedule_type|
            attendant, custom_selection = select_attendant(schedule_type, schedule_day)
            if attendant == "unresolved" && custom_selection
                rerun = true
                break
            end
            schedule_day << schedule_type.id2name[3..schedule_type.id2name.length] + " = " + attendant
        end
        rerun
    end

    def select_attendant(schedule_type, schedule_day)
        cur_attendant = ''
        custom_selection = false
        @schedule_data.data.each do |data|
            if data.schedule_type == schedule_type  # Get attendant from appropriate list
                data.schedule_day = schedule_day
                if data.respond_to?('select_attendant')
                    cur_attendant = custom_select_attendant(data, @schedule.index(schedule_day).even?)
                    custom_selection = true
                else
                    cur_attendant = data.get_attendant()
                end
                break
            end
        end
        [cur_attendant,custom_selection]
    end

    def reset_calendar()
        @schedule_data = @prep_schedule::Attendant_data_classes.new(@positions)
        calendar = gen_calendar(@year,@month,[SUN,WED]) {|y,m,d| Date::ABBR_DAYNAMES[Date.new(y,m,d).wday] + " " + d.to_s}
        @schedule = Array.new(calendar.length){|i| i = []}
        calendar
    end
    
    def logger()
        @logger = Logger.new(STDOUT, progname: 'fishy')
        @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
        @logger.level = Logger::DEBUG
    end
end