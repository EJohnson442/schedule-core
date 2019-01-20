require 'consecutive_days'
require 'files_helper'
require_relative 'config'
require_relative 'logging'

module Init_workers

    class Worker_data_classes
        include Files_helper
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
            load_file_data(Config::config_data['data_dir'] + task.to_s.capitalize + ".dat")
        end

        def load_file_data(full_filename)
            data = read_file_n2_array(full_filename)
            data.shuffle!
        end
    end
end
