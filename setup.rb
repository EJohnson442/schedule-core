require 'consecutive_days'
require_relative 'config'
require_relative 'logging'

module Prep_schedule
    include Config

    class Schedule_classes
        attr_reader :data

        def initialize(schedule_type_list)
            @data = []
            schedule_type_list.uniq.each { |p| @data << create_schedule_classes(p) }
        end

        def create_schedule_classes(schedule_type)
            info_create_schedule_classes("schedule_type = #{schedule_type}")
            schedule_class = Config::get_worker_classes(schedule_type)
            schedule_class.new(schedule_type) {|f| load_workers(Config.config_data['data_dir'] + schedule_type.to_s.capitalize + ".dat")}
        end

        def load_workers(full_filename)
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