require 'attendant'

class Sound < Attendant
    class << self                               #Class instance variables
        attr_accessor :sound_attendant1, :sound_attendant2
    end

    def get_attendant()
        found = true
        attendant = ""
        loop do
            attendant = super() {|candidate| found = (@@details.count_candidates_for_schedule_types(candidate, :ST_SOUND) > 0)}
            break if !found || (attendant == "unresolved")
        end
        
        schedule_attendant(attendant)
        attendant
    end

    @sound_attendant1 = ''
    @sound_attendant2 = ''
    def select_attendant(schedule_day_even)     #Sound attendants must be assigned two consecuvite days
        if schedule_day_even
            sound_attendant = get_attendant()
            self.class.sound_attendant1 == '' ? self.class.sound_attendant1 = sound_attendant : self.class.sound_attendant2 = sound_attendant
        else
            if self.class.sound_attendant1 != '' && self.class.sound_attendant2 != ''
                sound_attendant = self.class.sound_attendant1
                self.class.sound_attendant1 = ''
            else
                sound_attendant = self.class.sound_attendant2
                self.class.sound_attendant2 = ''
            end

            schedule_attendant(sound_attendant) 
        end
        sound_attendant
    end
end