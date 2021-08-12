require 'logging'

class Worker
    attr_reader :schedule_type, :workers

    DEFAULT_WORKER = "unresolved"
    
    @@scheduled_optimized = []
    @@scheduled = []
    @@priority_workers = []
    @@schedule_count = 0

    class << self                   #Class instance variables total_daily_tasks_count
        attr_accessor :daily_tasks_list_count, :max_monthly_assignments, :max_times_assigned_to_task, 
        :scheduled_days_count, :priority_schedule_types, :preserve_priority_workers, :rerun_max
    end

    def self.schedule_data()
        @@scheduled_optimized
    end

    def self.schedule_ready()
        keep_best_data_run()
        @@scheduled.clear
        self_schedule_ready_log(__method__,"@@scheduled_optimized defaults counted: #{@@scheduled.count_candidates(DEFAULT_WORKER, nil, @@scheduled_optimized)}") if @run_tests
        schedule_ready = ((@@schedule_count += 1) >= Worker.rerun_max)
    end

    def initialize(schedule_type)
        @schedule_type = schedule_type
        if block_given?
            @workers = yield(schedule_type)
            if @workers.length > 0 and Worker.priority_schedule_types.keys.include?(schedule_type.to_s)
                set_priority_workers(@workers)
            end
        end
    end

    def set_priority_workers(priority_workers)
        @@priority_workers.clear()
        total_workers_needed = Worker.priority_schedule_types[schedule_type.to_s].to_i
        if priority_workers.length <= total_workers_needed
            use_workers = priority_workers
        else
            use_workers = priority_workers[0..total_workers_needed - 1]
        end
        @@priority_workers.add_workers(use_workers)
    end

    def get_worker()
        worker = DEFAULT_WORKER
        worker_data = prioritize_workers()
        workers_scheduled = 0

        worker_data.each do |candidate|
            if block_given?
                if yield(candidate)
                    workers_scheduled += 1
                    worker = candidate
                    @@priority_workers.remove_worker(candidate) if !Worker.preserve_priority_workers
                    break
                end
            elsif !@@priority_workers.include?(candidate)
                if is_valid?(candidate)
                    workers_scheduled += 1
                    worker = candidate
                    schedule_worker(worker)
                    break
                end
            end
        end

        if (workers_scheduled == 0) && (self.class == Worker)
            worker = DEFAULT_WORKER
            schedule_worker(worker)
        end
        worker
    end

    def schedule_worker(worker)
        @@scheduled << {@schedule_type => worker}
    end

    protected
    def is_valid?(candidate)
        is_valid = true
        monthly_assignments_exceeded = @@scheduled.count_candidates(candidate) + 1 > self.class.max_monthly_assignments
        times_assigned_to_task_exceeded = @@scheduled.count_candidates(candidate, @schedule_type) + 1 > self.class.max_times_assigned_to_task
        multiple_assignments = candidate_in_prior_weeks?(candidate,0)

        if monthly_assignments_exceeded or times_assigned_to_task_exceeded or multiple_assignments
            is_valid = false
        end
        #TESTING SUGGESTS THAT THIS VALIDATION IS NOT VERY HELPFUL & SHOULD NOT BE USED
        #MORE SHOULD BE INVESTED IN MAXIMIZING CANDIDATE DISTRUBITION
        #TBD: FLESH OUT LOGIC w/ config entried
        is_valid
    end
#IN USE AND THESE WORK TOGETHER**************************************************************************
    def candidate_in_prior_weeks?(candidate, weeks = 1)
        data_range_config = {}
        data_range_config[:data_length] = @@scheduled.length
        data_range_config[:daily_tasks_count] = self.class.daily_tasks_list_count
        data_range_config[:schedule_count] = self.class.scheduled_days_count
        #weeks is usually 1/more. Determines how many weeks to consider including partial week
        #weeks = 0 will set :partial_week to true and: 
        #1) Calculate only remaining partial week. Check only the current week for the occurance of a worker
        #2) Review only prior weeks
		if weeks == 0
        	data_range_config[:partial_week] = true
		else
        	data_range_config[:partial_week] = false
		end
        data_range_config[:weeks] = weeks
        data_range_array = get_data_range_array(data_range_config)
        @@scheduled.found_candidate?(candidate, data_range_array)
    end

    def get_data_range_array(config)
        one_week = config[:daily_tasks_count] * config[:schedule_count]
        part_week = config[:data_length] % one_week
        if config[:partial_week]
            start_ndx = config[:data_length] < one_week ? 0 : config[:data_length] - (part_week)
        else
            start_ndx = config[:data_length] - ((one_week * config[:weeks]) + part_week)
        end
        end_ndx = config[:data_length] - 1
                    
        [start_ndx, end_ndx]
    end	

    def @@scheduled.found_candidate?(candidate, data_range_array)
        found = false
        range_data = self[data_range_array[0]..data_range_array[1]]
        range_data.each do |candidates|
            if candidates.values[0] == candidate
                found = true
                break
            end
        end
        found
    end

#IN USE AND THESE WORK TOGETHER**************************************************************************
    def @@scheduled.count_candidates(candidate, schedule_type = nil, data_array = nil)
        total = 0
        data = data_array == nil ? self : data_array
        data.each do |candidates|
            schedule_type != nil ? detail = candidates[schedule_type] : detail = candidates.values[0]
            total += 1 if detail == candidate
        end
        total
    end

    def @@scheduled.has_full_week_scheduled?()
        self.length >= Worker.daily_tasks_list_count * Worker.scheduled_days_count
    end
    #END: @@scheduled methods
    #BEGIN: @@priority_workers methods
    def @@priority_workers.add_workers(workers)
        workers.each {|worker| self.push(worker)}
    end

    def @@priority_workers.remove_worker(worker)
        #only delete first occurance
        if self.length > 0 and self.include?(worker)
            self.delete_at(self.index(worker))
        end
    end
    #BEGIN: @@priority_workers methods
    def prioritize_workers()     #order workers from least assigned to most assigned
        workers = []
        (0..@workers.length).each do |counter|
            @workers.each {|candidate| workers << candidate if @@scheduled.count_candidates(candidate) <= counter && !workers.include?(candidate)}
        end
        workers
    end

    def self.keep_best_data_run()    #preserve data with lowest occurance of DEFAULT_WORKER
        default_workers = 0
        if @@scheduled_optimized == []
            @@scheduled.each {|worker| @@scheduled_optimized << worker}  #must use clone() for this to work properly
            default_workers = @@scheduled.count_candidates(DEFAULT_WORKER)
        elsif ((default_workers = @@scheduled.count_candidates(DEFAULT_WORKER, nil, @@scheduled_optimized)) > @@scheduled.count_candidates(DEFAULT_WORKER))
            @@scheduled_optimized.clear()
            @@scheduled.each {|worker| @@scheduled_optimized << worker}
        end
        default_workers
    end    
end