require 'yaml'

module Config
    extend self
    
    WORKER_CLASSES = [Worker, Consecutive_days] #see if this info can be extracted
    
    attr_accessor :config_data

    def included(klass)
        load_config(File.open('config.yml')) if @config_data == nil
    end

    def load_config(config_source)
        @config_data = YAML::safe_load(config_source)
        @worker_classes = @config_data['classes_map'].keys
    end
    
    Make_worker_classes = Struct.new(:worker_classes, :classes_map) do
        def get_class_by_task(task)
            use_class = nil
            classes_map.each { |k,v| use_class = get_class(k) if v.include?(task.to_s)}
            use_class
        end
        
        private
            def get_class(task_class_name)
                use_class = nil
                worker_classes.each{ |c| use_class = c if task_class_name == c.to_s }
                use_class
            end
    end

    def get_worker_classes(task, classes_map = @config_data['classes_map'])
        wr = Config::Make_worker_classes.new(Config::WORKER_CLASSES, @config_data['classes_map'])
        wr.get_class_by_task(task)
    end
    
    def get_custom_data(worker_class, classes_map = @config_data['classes_map'])
        use_data = nil
        classes_map.each { |k,v| use_data = v[1..v.length - 1] if k == worker_class.class.to_s}
        use_data
    end
end