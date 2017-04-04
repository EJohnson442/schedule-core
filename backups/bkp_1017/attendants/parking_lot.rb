require 'attendant'

class Parking_Lot < Attendant
    def initialize()
        super(load_data(@@data_path + "Parking_Lot.dat").clone, :ST_PARKING_LOT)
    end
end
