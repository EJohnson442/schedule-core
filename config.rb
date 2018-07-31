require 'yaml'

module Config
    extend self
    
    WORKER_REGISTRY = [Worker, Consecutive_days]
    
    #attr_accessor :max_monthly_assignments, :max_times_assigned_to_task, :rerun_max, :month, :year, :daily_task_list, :scheduled_days, :consecutive_days, :data_dir, :position_class, :extensions
    attr_accessor :max_monthly_assignments, :max_times_assigned_to_task, :rerun_max, :month, :year, :daily_task_list, :scheduled_days, :consecutive_days, :data_dir, :position_class_map

    def included(klass)
        load_config(File.open('config.yml')) if @config_data == nil
    end

    def load_config(config_source)
        @config_data = YAML::load(File.open(config_source))
        @max_monthly_assignments = @config_data['max_monthly_assignments']
        @max_times_assigned_to_task = @config_data['max_times_assigned_to_task']
        @rerun_max = @config_data['rerun_max']
        @month = @config_data['month']
        @year = @config_data['year']
        @daily_task_list = @config_data['daily_task_list'].map(&:to_sym)
        @scheduled_days = @config_data['scheduled_days']
        @consecutive_days = @config_data['consecutive_days']
        @data_dir = @config_data['data_dir']
        @position_class_map = @config_data['position_class_map']
    end
    
    #get_class_by_task2 = 
    
    def get_class_by_task(task, worker_registry)
        use_class = nil
        @position_class_map.each { |k,v| use_class = get_class(k,worker_registry) if v.include?(task.to_s)}
        use_class
    end
    
    def get_class(task, worker_registry)
        use_class = nil
        worker_registry.each{ |c| use_class = c if task == c.to_s }
        use_class
    end
end