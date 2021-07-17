require 'worker'
require 'logging'

class Consecutive_days < Worker
    @@worker_list
    class << self
        attr_accessor :worker_list
    end

    def initialize(schedule_type)
        super(schedule_type)
        @days_count = 0
        self.class.worker_list = []
        @day_index = -1
    end

    def get_custom_worker(*args)
        # args[0] = day of week label, i.e., "Wed 7" & args[1] = consecutive days
        @consecutive_days = args[1]
        new_day(args[0]) if @current_day != args[0]
        if @days_count == 1                                 #first day
            worker = get_worker()
            self.class.worker_list << worker
        else
            worker = self.class.worker_list[@day_index += 1]
            schedule_worker(worker)
            @day_index = -1 if @day_index == self.class.worker_list.length - 1
        end
        get_custom_worker_log(__method__,args,@schedule_type,worker) if @run_tests
        worker
    end
    
    protected    
        def get_worker()
            add_to_schedule = false
            worker = Worker::DEFAULT_WORKER
            loop do
                # calls parent (worker.get_worker ()) and executes {|candidate| add_...} block at yield that returns true/false
                worker = super() {|candidate| add_to_schedule = is_valid(candidate)}
                break if add_to_schedule || (worker == Worker::DEFAULT_WORKER)
            end
            schedule_worker(worker)
            worker
        end
        
        def is_valid(candidate)
            if self.class.worker_list.include?(candidate)
                valid = false
            else
                valid = @@scheduled.count_candidates(candidate, @schedule_type) == 0
                valid or @@scheduled.count_candidates(candidate) + @consecutive_days <= Worker.max_monthly_assignments
            end
        end

        def new_day(current_day)
            @current_day = current_day
            if @consecutive_days < @days_count += 1     #first day
                @days_count = 1
                self.class.worker_list.clear()
            end
        end
end