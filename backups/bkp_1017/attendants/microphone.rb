require 'attendant'

class Microphone < Attendant
    def initialize()
        super(load_data(@@data_path + "Microphone.dat").clone, :ST_MICROPHONE)
    end
end
