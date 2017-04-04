require 'attendant'

class Sound < Attendant
    def initialize()
        data = load_data(@@data_path + "Sound.dat").clone
        super(data.clone, :ST_SOUND)
        @@sound_attendants = data.clone   #this dependency needs to be abstracted
    end

    def get_attendant()
        found = true
        attendant = ""
        loop do
            attendant = super() {|candidate| found = (assigned_count(candidate, :ST_SOUND) > 0)}
            break if !found || (attendant == "unresolved")
        end
        
        schedule_attendant(attendant)
        attendant
    end
end
