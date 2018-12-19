require 'consecutive_days'
require_relative 'config'
require_relative 'logging'

module Init_workers
    include Config

    class Worker_data_classes
        attr_reader :data

        def initialize(daily_task_list)
            @data = []
            daily_task_list.uniq.each { |p| @data << create_worker_classes(p) }
        end

        def create_worker_classes(task)
            worker_class = Config::worker_registry(task)
            worker_class.new(task) {|f| load_data(f)}
        end

        def load_data(task)
            load_file_data(Config.data_dir + task.to_s.capitalize + ".dat")
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
