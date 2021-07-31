require_relative 'validation'
require 'logging'

class Worker
    attr_reader :schedule_type, :workers

    DEFAULT_WORKER = "unresolved"
    
    @@scheduled_optimized = @@scheduled = []
    @@priority_workers = []

    class << self                   #Class instance variables total_daily_tasks
        attr_accessor :total_daily_tasks, :max_monthly_assignments, :max_times_assigned_to_task, :scheduled_days, :priority_schedule_types
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
                    @@priority_workers.remove_worker(candidate)
                    break
                end
            elsif !@@priority_workers.is_priority?(candidate)
                if is_valid?(candidate)
                    workers_scheduled += 1
                    worker = candidate
                    schedule_worker(worker)
                    break
                end
            end
        end

        if workers_scheduled == 0 && self.class == :workers
            puts "unresolved 2: #{@schedule_type} and class: #{self.class}"
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
            validate_data = Validator::Validate_data.new(self.class.max_monthly_assignments, candidate, @@scheduled,
                self.class.total_daily_tasks, self.class.scheduled_days, @schedule_type, self.class.max_times_assigned_to_task)
            validate_data.is_valid?()
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

        def @@scheduled.has_full_week_scheduled?()
            self.length >= Config::config_data["daily_task_list"].length * Config::config_data["scheduled_days"].length
        end

        def @@scheduled.prior_week_range()
            if self.has_full_week_scheduled?()
                tasks_per_week = Config::config_data["daily_task_list"].length * Config::config_data["scheduled_days"].length
                weeks_scheduled = self.length / tasks_per_week
                prior_week_start = (weeks_scheduled - 1) * tasks_per_week
                prior_week_end = (weeks_scheduled * tasks_per_week) - 1
                [prior_week_start, prior_week_end]
            end
        end

        def @@scheduled.prior_week_range2()     #this functionality should be determined externally by calling method 07.31.2021
            if self.has_full_week_scheduled?()
                tasks_per_week = Config::config_data["daily_task_list"].length * Config::config_data["scheduled_days"].length
                weeks_scheduled = self.length / tasks_per_week
                prior_week_start = (weeks_scheduled - 1) * tasks_per_week
                prior_week_end = (weeks_scheduled * tasks_per_week) - 1
                [prior_week_start, prior_week_end]
            end
        end

        def @@scheduled.found_in_prior_week(candidate)
            found = false
            if self.has_full_week_scheduled?()
                search = self.prior_week_range()    #yeah this is bad - to be reworked 07.31.2021
                range_data = self[search[0]..search[1]]
                range_data.each do |c|
                    if c.values[0] == candidate
                        found = true
                        break
                    end
                end                    
            end
            found
        end

        def @@scheduled.found_in_prior_week2(candidate)
            found = false
            if self.has_full_week_scheduled?()
                search = self.prior_week_range()
                range_data = self[search[0]..search[1]]
                range_data.each do |c|
                    if c.values[0] == candidate
                        found = true
                        break
                    end
                end                    
            end
            found
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