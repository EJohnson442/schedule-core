require 'attendant'
$LOAD_PATH << '.'
#require 'logging'

class Sound < Attendant
    @@sound_position1 = ''
    @@sound_position2 = ''
    
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

    def select_attendant(schedule_day_even)     #Sound attendants must be assigned two consecuvite days
        if schedule_day_even
            sound_attendant = get_attendant()
            @@sound_position1 == '' ? @@sound_position1 = sound_attendant : @@sound_position2 = sound_attendant
        else
            if @@sound_position1 != '' && @@sound_position2 != ''
                sound_attendant = @@sound_position1
                @@sound_position1 = ''
            else
                sound_attendant = @@sound_position2
                @@sound_position2 = ''
            end
        end
        sound_attendant
    end
end