require 'attendant'

class Seating < Attendant
    def initialize()
        super(load_data(@@data_path + "Seating.dat").clone, :ST_SEATING)
    end
end
