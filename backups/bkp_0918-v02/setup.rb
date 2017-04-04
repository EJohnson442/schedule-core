$LOAD_PATH << 'attendants'

require 'lobby'
require 'microphone'
require 'parking_lot'
require 'seating'
require 'sound'
require 'stage'

module Prep_schedule
    SCHEDULE_DATA = [Stage.new, Sound.new, Microphone.new, Seating.new, Lobby.new, Parking_Lot.new]

    POSITIONS = [:ST_SOUND, :ST_SOUND, :ST_STAGE, :ST_MICROPHONE, :ST_MICROPHONE, :ST_SEATING, :ST_SEATING, :ST_PARKING_LOT, :ST_PARKING_LOT, :ST_LOBBY]
end