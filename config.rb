require 'yaml'

module Config
    extend self

    WORKER_REGISTRY = [Worker, Consecutive_days]

    attr_accessor :month, :year, :data_dir, :config_data

    def included(klass)
        load_config(File.open('config.yml')) if @config_data == nil
    end

    def load_config(config_source)
        @config_data = YAML::load(File.open(config_source))
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

    def worker_registry(task, position_class_map = @config_data['position_class_map'])
        wr = Worker_registry.new(WORKER_REGISTRY, position_class_map)
        wr.get_class_by_task(task)
    end

    def get_worker_data(worker_class, position_class_map = @config_data['position_class_map'])
        use_data = nil
        position_class_map.each { |k,v| use_data = v[1..v.length - 1] if k == worker_class.class.to_s}
        use_data[0]
    end
end
