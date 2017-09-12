require 'attendant_processes'
require 'attendant'
require 'consecutive_days'
require_relative 'config'
require_relative 'logging'

module Prep_schedule
    include Attendant_data
    include Config

    class Attendant_data_classes
        attr_reader :data

        def initialize(positions)
            @data = []
            positions.uniq.each { |p| @data << create_attendant_classes(p) }
            if defined? Config.consecutive_days
                config_consecutive_days()
            else
                @data
            end
        end

        def config_consecutive_days()
            @data.map do |d|
                Config.consecutive_days.each do |k,v| 
                    if d.schedule_type == k.to_sym
                        d.consecutive_days = v
                    end
                end
            end
        end

        def create_attendant_classes(position)
            position == :ST_SOUND ? attendant_class = Consecutive_days : attendant_class = Attendant
            attendant_class.new(position) {|f| load_data(f)}
        end

        def load_data(position)
            Attendant_data.load_file_data("data/" << position.to_s.slice(3..-1).capitalize << ".dat")
        end
    end
end