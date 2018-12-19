require 'date'
require 'json'

module Calendar_formats
    FORMATS = [:native, :json, :task]
    CALENDAR_DATA = Struct.new(:fmt, :calendar, :daily_task_list, :schedule)
    
    Native_calendar = Struct.new(:calendar, :daily_task_list, :attendants) do
        def generate_calendar()
            schedule = []
            attendant_list = []
            attendants.each do |a|
                position = a.keys[0].id2name
                attendant_list << position + " = " + a.values[0]
            end

            (0..calendar.length - 1).each do
                daily_attendants = attendant_list.shift(daily_task_list.length)
                daily_attendants.insert(0,calendar.shift)
                schedule << daily_attendants
            end
            schedule
        end
    end
    
    JSON_calendar = Struct.new(:calendar, :schedule) do
        def generate_calendar()
            hash_schedule = {}
            daily_assignments = schedule.length / calendar.length
            calendar.each{|day| hash_schedule[day] = hash_roster(schedule.shift(daily_assignments))}     #problem is here
            JSON.generate(hash_schedule)
        end
        
        def hash_roster(roster)
            roster_data = {}
            roster.each do |data|
                if roster_data.has_key?data.keys[0]
                    roster_data[data.keys[0]] = manage_array(roster_data[data.keys[0]], data.values[0])
                else
                    roster_data[data.keys[0]] = data.values[0]
                end
            end
            roster_data
        end
        
        def manage_array(curr_value,new_value)
            if curr_value.class == Array
                curr_value << new_value
            else
                arr_value = []
                arr_value << curr_value
                arr_value << new_value
                curr_value = arr_value
            end
        end
    end

    Task_view_calendar = Struct.new(:calendar) do
        def generate_calendar()
            schedule = []
            calendar.each do |schedule_day|
                schedule_day.each {|attendant| schedule << "#{attendant}"}
                schedule << " "
            end
        end
    end

    def calendar(calendar_data)
        calendar_run = nil
        case calendar_data.fmt
            when :native
                calendar_run = Native_calendar.new(calendar_data.calendar, calendar_data.daily_task_list, calendar_data.schedule)
            when :json
                calendar_run = JSON_calendar.new(calendar_data.calendar, calendar_data.schedule)
            when :task
                native_run = Native_calendar.new(calendar_data.calendar, calendar_data.daily_task_list, calendar_data.schedule)
                calendar_run = Task_view_calendar.new(native_run.generate_calendar())
            else    
                raise RuntimeError.new("'generate_calendar' must be one of the following: #{FORMATS}")
        end
        calendar_run.generate_calendar()
    end
end