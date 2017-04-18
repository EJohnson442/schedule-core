require 'date'
require_relative 'utils'

class Monthly_Schedule
    include Schedule_helper
    attr_accessor :sound_position, :rerun_max
    def initialize(schedule_data, positions, year, month)
        @positions = positions.clone
        @schedule_data_bkp = schedule_data.clone
        @year = year
        @month = month
    end

    def make_schedule()
        if sound_position == nil || rerun_max == nil
            puts "sound_position\\rerun_max undefined"
            exit
        end
        
        rerun_cnt = 0
        begin
            @rerun = false
            reset_data()
            calendar = @calendar
            @schedule.each do |schedule_day|
                new_schedule(schedule_day,calendar)
                if @rerun
                    Attendant.data_reset()
                    break
                end
            end

            rerun_cnt += 1
            break if rerun_cnt > rerun_max
        end while @rerun == true
        showdata(@schedule) if rerun_cnt <= rerun_max
    end

    protected
    def new_schedule(schedule_day,calendar)
        #update schedule date here
        schedule_day << calendar.shift
        @positions.each do |schedule_type|
            attendant = select_attendant(schedule_type, schedule_day)
            if attendant == "unresolved" && schedule_type != sound_position
                @rerun = true
                break
            end
            schedule_day << schedule_type.id2name[3..schedule_type.id2name.length] + " = " + attendant
        end
    end

    def select_attendant(schedule_type, schedule_day)
        cur_attendant = ''
        @schedule_data.data.each do |data|
            if data.schedule_type == schedule_type  # Get attendant from appropriate list
                data.schedule_day = schedule_day
                cur_attendant = data.respond_to?('select_attendant') ? data.select_attendant(@schedule.index(schedule_day).even?) : data.get_attendant()
                break
            end
        end
        cur_attendant
    end

    def reset_data()
        @sound_attendant1 = ''
        @sound_attendant2 = ''
        @schedule_data = @schedule_data_bkp.clone
        @calendar = gen_calendar(@year,@month)
        @schedule = Array.new(@calendar.length){|i| i = []}
    end
end