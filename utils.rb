require 'date'
require 'json'

module Calendar_formats
    Raw_calendar = Struct.new(:calendar, :positions, :attendants) do
        def generate_calendar()
            schedule = []
            attendant_list = []
            attendants.each do |a|
                position = a.keys[0].id2name
                attendant_list << position + " = " + a.values[0]
            end

            (0..calendar.length - 1).each do
                daily_attendants = attendant_list.shift(positions.length)
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
            calendar.each{|day| hash_schedule[day] = hash_roster(schedule.shift(daily_assignments))}
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
        
    def task_view_calendar(raw_calendar)
        raw_calendar.each do |schedule_day|
            schedule_day.each {|attendant| puts "#{attendant}"}
            puts "\n"
        end
    end
end