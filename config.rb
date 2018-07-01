require 'yaml'

module Config
    extend self
    
    attr_reader :config_data, :monthly_assignments, :weekly_assignments, :max_assigned_to_task, :rerun_max, :month, :year, :positions, :scheduled_days, :consecutive_days, :data_dir

    def included(klass)
        load_config(File.open('config.yml')) if @config_data == nil
    end

    def load_config(config_source)
        @config_data = YAML::load(File.open(config_source))
        @monthly_assignments = @config_data['monthly_assignments']
        @weekly_assignments = @config_data['weekly_assignments']
        @max_assigned_to_task = @config_data['max_assigned_to_task']
        @rerun_max = @config_data['rerun_max']
        @month = @config_data['month']
        @year = @config_data['year']
        @positions = @config_data['positions'].map(&:to_sym)
        @scheduled_days = @config_data['scheduled_days']
        @consecutive_days = @config_data['consecutive_days']
        @data_dir = @config_data['data_dir']
    end
end