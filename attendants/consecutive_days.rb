require 'attendant'
$LOAD_PATH << '.'
require 'logging'

class Consecutive_days < Attendant
    class << self
        attr_accessor :consecutive_days, :current_day, :attendants, :days_count
    end

    def initialize(schedule_type, consecutive_days = 2)
        super(schedule_type)
        self.class.consecutive_days = consecutive_days
        self.class.days_count = 0
        self.class.attendants = []
        @index = -1
    end
    
    def custom_attendant(current_day)
        process_day(current_day)
        if self.class.days_count == 1                                       #first day
            attendant = get_attendant()
            self.class.attendants << attendant
        else
            attendant = self.class.attendants[@index += 1]
            @index = -1 if @index == self.class.attendants.length - 1
        end
        attendant
    end
    
    protected    
        def get_attendant()
            add_to_schedule = false
            attendant = "unresolved"
            loop do
                #'add_to_schedule' is returned to yield
                #add to schedule if not already scheduled
                attendant = super() {|candidate| add_to_schedule = (@@scheduled.count_candidates(candidate, @schedule_type) == 0)}
                Logs.debug("add_to_schedule = #{add_to_schedule} & attendant = #{attendant}")
                break if add_to_schedule || (attendant == "unresolved")
            end
            
            schedule_attendant(attendant)
            attendant
        end
        
        def process_day(current_day)
            if self.class.current_day != current_day
                self.class.current_day = current_day
                if self.class.consecutive_days < self.class.days_count += 1     #first day
                    self.class.days_count = 1
                    self.class.attendants.clear()
                end
            end
        end
end