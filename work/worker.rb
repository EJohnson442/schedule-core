require_relative 'validation'
require 'logging'

class Worker
    include Validator
    attr_reader :schedule_type, :workers

    DEFAULT_WORKER = "unresolved"

    @@scheduled_optimized = @@scheduled = []

    class << self                   #Class instance variables
        attr_accessor :total_tasks, :max_monthly_assignments, :max_times_assigned_to_task, :scheduled_days
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
        end
    end

    def get_worker()
        worker = DEFAULT_WORKER
        mode = :initial
        worker_data = prioritize_workers()

        worker_data.each do |candidate|
            if block_given?
                mode = :custom
                if yield(candidate)
                    worker = candidate
                    break
                end
            else
                mode = :general
                if is_valid(candidate) {|v| validate(v)}
                    worker = candidate
                    break
                end
            end
        end

        schedule_worker(worker) if mode == :general
        worker
    end

    def schedule_worker(worker)
        @@scheduled << {@schedule_type => worker}
    end

    protected
        def is_valid(candidate)
            validate_data = VALIDATE_DATA.new(self.class.max_monthly_assignments,candidate,@schedule_type,self.class.max_times_assigned_to_task,@@scheduled,self.class.total_tasks, self.class.scheduled_days)
            yield(validate_data)
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
end
