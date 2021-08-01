require 'worker'
require 'logging'

class Consecutive_days < Worker
    def initialize(schedule_type)
        super(schedule_type)
        @days_count = 0
        @worker_list = []
        @day_index = -1
    end

    def get_custom_worker(*args)
        # args[0] = day of week label, i.e., "Wed 7" & args[1] = consecutive days
        @consecutive_days = args[1]
        new_day(args[0]) if @current_day != args[0]
        if @days_count == 1
            # first day
            # workers are only determined on the first day.
            # Any other day is a consecutive day and always has the same workers.
            worker = get_worker()
            @worker_list << worker
        else
            worker = @worker_list[@day_index += 1]
            @day_index = -1 if @day_index == @worker_list.length - 1
        end
        schedule_worker(worker)
        get_custom_worker_log(__method__,args,@schedule_type,worker) if @run_tests
        worker
    end
    
    protected    
        def get_worker()
            add_to_schedule = false
            worker = Worker::DEFAULT_WORKER
            loop do
                # calls parent (worker.get_worker ()) and executes {|candidate| add_...} block that returns true/false at yield
                worker = super() {|candidate| add_to_schedule = is_valid?(candidate)}
                break if add_to_schedule || (worker == Worker::DEFAULT_WORKER)
            end
            worker
        end

        def is_valid?(candidate)
            is_valid = !@worker_list.include?(candidate)
            if @@scheduled.has_full_week_scheduled?()
                if @@scheduled.found_in_prior_week(candidate)
                    is_valid = false
                end
            end
            is_valid
        end

        def new_day(current_day)
            @current_day = current_day
            if @consecutive_days < @days_count += 1     #first day
                @days_count = 1
                @worker_list.clear()
            end
        end
end