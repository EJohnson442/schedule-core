require 'attendant'

class Sound < Attendant
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
end
