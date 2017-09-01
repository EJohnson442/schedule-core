require 'date'

module Schedule_helper  #Rename Calendar_helper
#    MON = 1             #THESE DATE VARIABLES MAYBE DUPLICATING WORK DONE BY RUBY
#    TUE = 2
#    WED = 3
#    THU = 4
#    FRI = 5
#    SAT = 6
#    SUN = 7

    def gen_calendar(year, month, days_of_week = [])
        calendar = []
        day = 0
        until !Date.valid_date?(year,month,day += 1)
            if days_of_week.include?(Date.new(year,month,day).cwday) || days_of_week == []
                block_given? ? calendar << yield(year,month,day) : calendar << day.to_s
            end
        end
        calendar
    end
    
    def showdata(schedule)  #This should be moved to a test module
        schedule.each do |schedule_day|
            schedule_day.each {|attendant| puts "#{attendant}"}
            puts "\n"
        end
    end
end