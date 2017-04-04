require 'attendant'

class Sound < Attendant
    ATND_TYPE = :ST_SOUND
    def initialize()
        data = load_data(@@data_path + "Sound.dat").clone
        super(data.clone, ATND_TYPE)
        @@sound_attendants = data.clone   #this dependency needs to be abstracted
    end

    def get_attendant()
        found = true
        attendant = ""
        loop do
            attendant = super() {|candidate| found = (sound_assignments(candidate) > 0)}
            break if !found || (attendant == "unresolved")
        end
        
        schedule_attendant(attendant)
        attendant
    end
    
    def sound_assignments(candidate)
        stats = details_stats
        stats.call candidate, ATND_TYPE
    end
end
