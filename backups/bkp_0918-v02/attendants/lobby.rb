require 'attendant'

class Lobby < Attendant
    def initialize()
        super(load_data(@@data_path + "Lobby.dat").clone, :ST_LOBBY)
    end
end
