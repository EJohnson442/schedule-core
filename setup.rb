$LOAD_PATH << 'attendants'
require 'attendant_processes'
require 'attendant'
require 'sound'

module Prep_schedule
    include Attendant_data

    POSITIONS = [:ST_SOUND, :ST_SOUND, :ST_STAGE, :ST_MICROPHONE, :ST_MICROPHONE, :ST_SEATING, :ST_SEATING, :ST_PARKING_LOT, :ST_PARKING_LOT, :ST_LOBBY]

    class Attendant_data_classes
        attr_reader :data
        def initialize(positions)
            @data = []
            filtered_positions = []
            positions.each do |p|
                if !filtered_positions.include?(p)
                    @data << create_attendant_classes(p)
                    filtered_positions << p
                end
            end
        end
    
        def create_attendant_classes(position)
            if position == :ST_SOUND
             attendant = Sound.new(position) {|f| Attendant_data.load_file_data("data/" << f.to_s.slice(3..f.to_s.length - 1).capitalize << ".dat")}
            else
             attendant = Attendant.new(position) {|f| Attendant_data.load_file_data("data/" << f.to_s.slice(3..f.to_s.length - 1).capitalize << ".dat")}
            end
            #attendant.attendants   RANDOMIZE THIS DATA
        end
    end
end