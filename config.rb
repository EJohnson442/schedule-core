require 'yaml'

module Config
    extend self
    
    WORKER_REGISTRY = [Worker, Consecutive_days]
    
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
    
    Worker_registry = Struct.new(:worker_registry, :position_class_map) do
        def get_class_by_task(task)
            use_class = nil
            position_class_map.each { |k,v| use_class = get_class(k) if v.include?(task.to_s)}
            use_class
        end
        
        private
            def get_class(task_class_name)
                use_class = nil
                worker_registry.each{ |c| use_class = c if task_class_name == c.to_s }
                use_class
            end
    end

    def worker_registry(task, worker_registry = Config::WORKER_REGISTRY, position_class_map = Config::position_class_map)
        wr = Config::Worker_registry.new(Config::WORKER_REGISTRY, Config::position_class_map)
        wr.get_class_by_task(task)
    end
    
    def get_worker_data(worker_class, position_class_map = Config::position_class_map)
        use_data = nil
        position_class_map.each { |k,v| use_data = v[1..v.length - 1] if k == worker_class.class.to_s}
        use_data
    end
end