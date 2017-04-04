require 'attendant'

class Stage < Attendant
    def initialize()
        super(load_data(@@data_path + "Stage.dat").clone, :ST_STAGE)
    end
end
