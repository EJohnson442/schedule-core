require 'date'

class Monthly_Schedule
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
                if @rerun == true
                    Attendant.data_reset()
                    break
                end
            end

            rerun_cnt += 1
            break if rerun_cnt > rerun_max
        end while @rerun == true
        showdata() if rerun_cnt <= rerun_max
    end

    protected
    def gen_calendar(year, month)
        calendar = []
        day = 0
        until !Date.valid_date?(year,month,day += 1)
            if Date.new(year,month,day).sunday? || Date.new(year,month,day).wednesday?
                calendar << Date::ABBR_DAYNAMES[Date.new(year,month,day).wday]+" "+day.to_s
            end
        end
        calendar.clone
    end

    def new_schedule(schedule_day,calendar)
        #update schedule date here
        schedule_day << calendar.shift
        @positions.each do |attendant_type|
            attendant = attendant_type == sound_position ? sound_mgr(schedule_day, sound_position) : select_attendant(attendant_type, schedule_day)
            if attendant == "unresolved" && attendant_type != sound_position
                @rerun = true
                break
            end
            schedule_day << attendant_type.id2name[3..attendant_type.id2name.length] + " = " + attendant
        end
    end

    def reset_data()
        @sound_attendant1 = ''
        @sound_attendant2 = ''
        @schedule_data = @schedule_data_bkp.clone
        @calendar = gen_calendar(@year,@month)
        @schedule = Array.new(@calendar.length){|i| i = []}
    end
    
    #Enforce each sound attendant assignment must be for two consecutive days
    def sound_mgr(schedule_day, attendant_type)
        if @schedule.index(schedule_day).even?
            sound_attendant = select_attendant(attendant_type, schedule_day)
            @sound_attendant1 == '' ? @sound_attendant1 = sound_attendant : @sound_attendant2 = sound_attendant
        else
            if @sound_attendant1 != '' && @sound_attendant2 != ''
                sound_attendant = @sound_attendant1
                @sound_attendant1 = ''
            else
                sound_attendant = @sound_attendant2
                @sound_attendant2 = ''
            end

            @schedule_data.data.each do |data|
                if data.schedule_type == attendant_type
                    data.schedule_attendant(sound_attendant) 
                    break
                end
            end
        end
        sound_attendant
    end

    def select_attendant(schedule_type, schedule_day)
        cur_attendant = ''
        @schedule_data.data.each do |data|
            if data.schedule_type == schedule_type  # Get attendant from appropriate list
                data.schedule_day = schedule_day
                cur_attendant = data.get_attendant()
                break
            end
        end
        cur_attendant
    end

    def showdata()
        @schedule.each do |schedule_day|
            schedule_day.each {|attendant| puts "#{attendant}"}
            puts "\n"
        end
    end
end
