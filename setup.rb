require 'consecutive_days'
require_relative 'config'
require_relative 'logging'

module Prep_schedule
    include Config

    class Attendant_data_classes
        attr_reader :data

        def initialize(positions)
            @data = []
            positions.uniq.each { |p| @data << create_attendant_classes(p) }
        end

        def create_attendant_classes(position)
            Config.consecutive_days.has_key?(position.to_s) ? attendant_class = Consecutive_days : attendant_class = Attendant
            attendant_class.new(position) {|f| load_data(f)}
        end

        def load_data(position)
            load_file_data(Config.data_dir + position.to_s.capitalize + ".dat")
        end
        
        def load_file_data(full_filename)
            data = []
            File.open(full_filename, "r") do |f|
                f.each_line do |line|
                    line.include?("\n") ? data << line.chop! : data << line
                end
            end
            data.shuffle!
        end
    end
end