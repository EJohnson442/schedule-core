require 'logging'
require_relative 'validation'
#require_relative 'worker_helper'

class Worker
    attr_reader :schedule_type, :workers

    DEFAULT_WORKER = "unresolved"
    
    @@scheduled_optimized = []
    @@scheduled = []
    @@priority_workers = []
    @@schedule_count = 0

    class << self                   #Class instance variables total_daily_tasks_count
        attr_accessor :daily_tasks_list_count, :max_monthly_assignments, :max_times_assigned_to_task,:scheduled_days_count,
        :priority_schedule_types, :preserve_priority_workers, :rerun_max, :validate_weeks, :cdays_validate_weeks
    end

    def self.schedule_data()
        @@scheduled_optimized
    end

    def self.schedule_ready()
        keep_best_data_run()
        @@scheduled.clear
        self_schedule_ready_log(__method__,
            "@@scheduled_optimized defaults counted: #{@@scheduled.count_candidates(DEFAULT_WORKER, nil, @@scheduled_optimized)}") if @run_tests
        schedule_ready = ((@@schedule_count += 1) >= Worker.rerun_max)
    end

    def initialize(schedule_type)
        @schedule_type = schedule_type
        if block_given?
            @workers = yield(schedule_type)
            if (@workers.length > 0) and Worker.priority_schedule_types.keys.include?(schedule_type.to_s)
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
        @@priority_workers = workers.dup
    end

    def get_worker()
        worker = DEFAULT_WORKER
        worker_data = prioritize_workers()
        workers_scheduled = 0

        worker_data.each do |candidate|
            if block_given?
                if yield(candidate)
                    worker = candidate
                    @@priority_workers.delete(candidate) if (@@priority_workers.size > 0) && !Worker.preserve_priority_workers
                    break
                end
            elsif is_valid?(candidate)
                workers_scheduled += 1
                worker = candidate
                schedule_worker(worker)
                break
            end
        end

        schedule_worker(DEFAULT_WORKER) if (workers_scheduled == 0) && (self.class == Worker)
        worker
    end

    def schedule_worker(worker)
        @@scheduled << {@schedule_type => worker}
    end

    protected
    def is_valid?(candidate)
        worker_data = Validate::Worker_data.new(candidate,@@scheduled,self.class.daily_tasks_list_count,self.class.scheduled_days_count,
            self.class.validate_weeks,self.class.max_monthly_assignments, self.class.max_times_assigned_to_task, @schedule_type, @@priority_workers)

        Validate::is_valid?(worker_data)
    end

    def @@scheduled.count_candidates(candidate, schedule_type = nil, data_array = nil)
        total = 0
        data = data_array == nil ? self : data_array
        data.each do |candidates|
            schedule_type != nil ? detail = candidates[schedule_type] : detail = candidates.values[0]
            total += 1 if detail == candidate
        end
        total
    end
    
    def prioritize_workers()     #order workers from least assigned to most assigned
        workers = []
        (0..@workers.length).each do |counter|
            @workers.each do |candidate| 
                workers << candidate if (@@scheduled.count_candidates(candidate) <= counter)
                break if workers.count == @workers.count
            end
        end
        workers
    end

    def self.keep_best_data_run()    #preserve data with lowest occurance of DEFAULT_WORKER
        if (@@scheduled_optimized == []) || 
            ((@@scheduled.count_candidates(DEFAULT_WORKER, nil, @@scheduled_optimized)) > @@scheduled.count_candidates(DEFAULT_WORKER))
            @@scheduled_optimized = @@scheduled.dup
        end
    end    
end