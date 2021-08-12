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
            if @@scheduled.has_full_week_scheduled?()   #THIS IS ABSOLUTELY NECESSARY!!!!!
                if candidate_in_prior_weeks?(candidate)
                    is_valid = false
                end
            end
            count_candidates = @@scheduled.count_candidates(candidate) + 2
            (is_valid and count_candidates <= Worker.max_monthly_assignments)
        end

        def candidate_in_prior_weeks?(candidate, weeks = 1)
            tasks_per_week = Worker.daily_tasks_list_count * Worker.scheduled_days_count
            data_length = @@scheduled.length
            if data_length >= tasks_per_week
                #Ensures same data range while reviewing multiple days
                consec_days_adjust = data_length % tasks_per_week
                start_ndx = data_length - tasks_per_week > 0 ? data_length - tasks_per_week : 0
                end_ndx = data_length - 1
                if consec_days_adjust > 0
                    start_ndx = start_ndx - consec_days_adjust
                    end_ndx = end_ndx - consec_days_adjust
                end
                candidate_in_prior_weeks_log(__method__, start_ndx, data_length - 1, tasks_per_week, data_length) if @run_tests
                found_it = @@scheduled.found_candidate?(candidate, [start_ndx, end_ndx])
            end
            found_it
        end

        def new_day(current_day)
            @current_day = current_day
            if @consecutive_days < @days_count += 1     #first day
                @days_count = 1
                @worker_list.clear()
            end
        end
end