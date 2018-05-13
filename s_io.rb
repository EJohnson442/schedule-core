require 'json'

class Schedules_IO
    attr_reader :schedule, :schedule_dates

    def initialize()
        @schedule_dates = []
        @schedule = []
    end
    
    def write_schedule(filename, calendar, schedule)
        open(filename, 'w') {|f| f.puts to_(calendar, schedule)}
    end

    def read_schedule(filename)
        data_file = []
        open(filename, "r") do |f|
            f.each_line do |line|
                line.include?("\n") ? data_file << line.chop! : data_file << line
            end
        end
        
        to_array(data_file)
    end
    
    private
        #write_schedules
        def to_(calendar, schedule)
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
        
        #read_schedules
        def to_array(data_file)
            data_string = data_file[0].to_s
            hash_data = JSON.parse(data_string)
            
            hash_data.each do |key, value|
                @schedule_dates << key
                schedules(value)
            end
        end

        def schedules(values)
            values.each do |key, value|
                value.class == Array ? value.each{|v| schedule << {key.to_sym => v}} : schedule << {key.to_sym => value}
            end
        end
end