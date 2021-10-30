module Validate
    extend self

    Worker_data = Struct.new(:candidate, :data, :daily_tasks_list_count, :scheduled_days_count, :weeks, 
        :max_monthly_assignments, :max_times_assigned_to_task, :schedule_type, :priority_workers)
    
    def is_valid?(worker_data)
        is_valid = !worker_data.priority_workers.include?(worker_data.candidate)
        if is_valid
            #monthly assignments exceeded
            return false if (worker_data.data.count_candidates(worker_data.candidate) + 1 > worker_data.max_monthly_assignments)
            #times assigned to task exceeded
            return false if (worker_data.data.count_candidates(worker_data.candidate, worker_data.schedule_type) + 1 > worker_data.max_times_assigned_to_task)
            #multiple weekly assignments
            return false if candidate_in_prior_weeks?(worker_data)
        end
        
        is_valid
    end

    def candidate_in_prior_weeks?(worker_data)
        data_range_array = get_data_range_array(worker_data)
        found_candidate?(worker_data.candidate, worker_data.data, data_range_array)
    end

    def get_data_range_array(worker)
        one_week = worker.daily_tasks_list_count * worker.scheduled_days_count
        part_week = worker.data.length % one_week
        if worker.weeks == 0   #partial week
            start_ndx = worker.data.length < one_week ? 0 : worker.data.length - (part_week)
        else
            start_ndx = worker.data.length - ((one_week * worker.weeks) + part_week)
        end
        start_ndx = 0 if start_ndx < 0
        end_ndx = worker.data.length - 1
                    
        [start_ndx, end_ndx]
    end	

    def found_candidate?(candidate, data, data_range_array)
        found = false
        range_data = data[data_range_array[0]..data_range_array[1]]
        range_data.each do |candidates|
            if candidates.values[0] == candidate
                found = true
                break
            end
        end
        found
    end

    #module_function :candidate_in_prior_weeks?
    private :get_data_range_array, :found_candidate?
end