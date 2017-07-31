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
            positions.uniq.each { |p| @data << create_attendant_classes(p) }
            @data
        end

        def create_attendant_classes(position)
            position == :ST_SOUND ? attendant_class = Sound : attendant_class = Attendant
            attendant_class.new(position) {|f| load_data(f)}
        end

        def load_data(position)
            Attendant_data.load_file_data("data/" << position.to_s.slice(3..-1).capitalize << ".dat")
        end
    end
end