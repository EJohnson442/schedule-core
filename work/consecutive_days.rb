require 'worker'
require 'logging'

class Consecutive_days < Worker
    attr_accessor :consecutive_days #this is being used but it's redundant and this needs to change
    
    class << self
        attr_accessor :worker_list
    end

    #def initialize(schedule_type, consecutive_days = 2)
    def initialize(schedule_type, consecutive_days = 2)
        super(schedule_type)
        #@consecutive_days = consecutive_days
        @days_count = 0
        self.class.worker_list = []
        @index = -1
    end

    #def get_custom_attendant(current_day)
    def get_custom_attendant(*args)
        new_day(args[0]) if @current_day != args[0]
        @consecutive_days = args[1]
        if @days_count == 1                                     #first day
            worker = get_worker()
            self.class.worker_list << worker
        else
            worker = self.class.worker_list[@index += 1]
            schedule_worker(worker)
            @index = -1 if @index == self.class.worker_list.length - 1
        end
        worker
    end
    
    protected    
        def get_worker()
            add_to_schedule = false
            worker = Worker::DEFAULT_WORKER
            loop do
                #'add_to_schedule' is returned to yield/add to schedule if not already scheduled
                worker = super() {|candidate| add_to_schedule = (@@scheduled.count_candidates(candidate, @schedule_type) == 0)}
                break if add_to_schedule || (worker == Worker::DEFAULT_WORKER)
            end
            
            schedule_worker(worker)
            worker
        end
        
        def new_day(current_day)
            @current_day = current_day
            if @consecutive_days < @days_count += 1     #first day
                @days_count = 1
                self.class.worker_list.clear()
            end
        end
end