require 'consecutive_days'
require_relative 'files_helper'
require 'config'
require 'logging'

module Worker_helper
  class Worker_data_classes
    include Files_helper
    attr_reader :data

    def initialize(daily_task_list)
      @data = []
      daily_task_list.uniq.each { |p| @data << create_worker_classes(p) }
    end

    def create_worker_classes(task)
      worker_class = Config::classes_registry(task)
      worker_class.new(task) {|f| load_data(f)}
    end

    def load_data(task)
      if Config::load_config_data_files
        load_file_data(Config::config_data['data_dir'] + task.to_s.capitalize + ".dat")
      else
      end
    end

    def load_file_data(full_filename)
      data = read_file_n2_array(full_filename)
      data.shuffle!
    end
  end
end
