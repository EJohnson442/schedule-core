require 'date'

module Schedule_helper  #Rename Calendar_helper
    def showdata(schedule)  #This should be moved to a test module
        schedule.each do |schedule_day|
            schedule_day.each {|attendant| puts "#{attendant}"}
            puts "\n"
        end
    end
end