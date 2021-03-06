require_relative 'validation'
#require_relative 'validation_dev'
require 'logging'

class Worker
    attr_reader :schedule_type, :workers

    DEFAULT_WORKER = "unresolved"
    
    @@scheduled_optimized = @@scheduled = []
    @@priority_workers = []

    class << self                   #Class instance variables
        attr_accessor :total_tasks, :max_monthly_assignments, :max_times_assigned_to_task, :scheduled_days, :priority_schedule_types
    end

    #access class variables
    def self.scheduled()
        @@scheduled_optimized = [] ? @@scheduled.clone : @@scheduled_optimized.clone
    end

    def self.data_reset()
        keep_best_data_run()
        @@scheduled.clear
    end

    def initialize(schedule_type)
        @schedule_type = schedule_type
        if block_given?
            @workers = yield(schedule_type)
            if @workers.length > 0 && Worker.priority_schedule_types.keys.include?(schedule_type.to_s)
                set_priority_workers(@workers)
            end
        end
    end

    def set_priority_workers(priority_workers)
        @@priority_workers.clear()
        total_workers_needed = Worker.priority_schedule_types[schedule_type.to_s].to_i
        if priority_workers.length < total_workers_needed
            use_workers = priority_workers
        else
            use_workers = priority_workers[0..total_workers_needed - 1]
        end
        @@priority_workers.add_workers(use_workers)
    end

    def get_worker()
        worker = DEFAULT_WORKER
        worker_data = prioritize_workers()

        worker_data.each do |candidate|
            if block_given?
                if yield(candidate)
                    worker = candidate
                    @@priority_workers.remove_worker(candidate)
                    break
                end
            elsif !@@priority_workers.is_priority?(candidate)
                @data_set_test = create_data_set(candidate)
                if  is_valid?(candidate) {|v| Validator::is_valid?(@data_set_test)}
                    worker = candidate
                    schedule_worker(worker)
                    break
                end
            end
        end
        worker
    end

    def schedule_worker(worker)
        @@scheduled << {@schedule_type => worker}
    end

    protected
        def is_valid?(candidate)
            yield(Validator::is_valid?(@data_set_test))
        end

        def create_data_set(candidate)
            data_set = {}
            data_set["max_monthly_assignments"] = self.class.max_monthly_assignments
            data_set["candidate"] = candidate
            data_set["schedule_type"] = @schedule_type
            data_set["max_times_assigned_to_task"] = self.class.max_times_assigned_to_task
            data_set["scheduled"] = @@scheduled
            data_set["total_tasks"] = self.class.total_tasks
            data_set["scheduled_days"] = self.class.scheduled_days
            data_set.freeze
        end

        def @@scheduled.count_candidates(candidate, schedule_type = nil)
            total = 0
            each do |c|
                schedule_type != nil ? detail = c[schedule_type] : detail = c.values[0]
                total += 1 if detail == candidate
            end
            total
        end

        def @@scheduled.position_of(candidate)
            pos = 0
            each { |c| c.values[0] == candidate ? break : pos += 1 }
            pos
        end

        def prioritize_workers()     #order workers from least assigned to most assigned
            workers = []
            (0..@workers.length).each do |counter|
                @workers.each {|candidate| workers << candidate if @@scheduled.count_candidates(candidate) <= counter && !workers.include?(candidate)}
            end
            workers
        end
        
        def self.keep_best_data_run()    #preserve data with lowest occurance of DEFAULT_WORKER
            if @@scheduled_optimized == [] ||
                @@scheduled_optimized.count_candidates(DEFAULT_WORKER) > @@scheduled.count_candidates(DEFAULT_WORKER)
                @@scheduled_optimized = @@scheduled.dup
            end
        end

        def @@priority_workers.add_workers(workers)
            workers.each {|worker| self.push(worker)}
        end

        def @@priority_workers.remove_worker(worker)
            #only delete first occurance
            if self.length > 0 and self.include?(worker)
                self.delete_at(self.index(worker))
            end
        end

        def @@priority_workers.is_priority?(worker)
            self.include?(worker)
        end
end