require 'attendant'
require 'logging'

class Consecutive_days < Attendant
    class << self
        attr_accessor :attendants
    end

    def initialize(schedule_type, consecutive_days = 2)
        super(schedule_type)
        @consecutive_days = consecutive_days
        @days_count = 0
        self.class.attendants = []
        @index = -1
    end
    
    def custom_attendant(current_day)
        new_day(current_day) if @current_day != current_day
        if @days_count == 1                                     #first day
            attendant = get_attendant()
            self.class.attendants << attendant
        else
            attendant = self.class.attendants[@index += 1]
            schedule_attendant(attendant)
            @index = -1 if @index == self.class.attendants.length - 1
        end
        attendant
    end
    
    protected    
        def get_attendant()
            add_to_schedule = false
            attendant = "unresolved"
            loop do
                #'add_to_schedule' is returned to yield/add to schedule if not already scheduled
                attendant = super() {|candidate| add_to_schedule = (@@scheduled.count_candidates(candidate, @schedule_type) == 0)}
                break if add_to_schedule || (attendant == "unresolved")
            end
            
            schedule_attendant(attendant)
            attendant
        end
        
        def new_day(current_day)
            @current_day = current_day
            if @consecutive_days < @days_count += 1     #first day
                @days_count = 1
                self.class.attendants.clear()
            end
        end
end