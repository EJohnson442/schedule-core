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
        data_range_config = {}
        data_range_config[:data_length] = worker_data.data.length
        data_range_config[:daily_tasks_count] = worker_data.daily_tasks_list_count
        data_range_config[:schedule_count] = worker_data.scheduled_days_count
        #weeks is usually >= 1. Determines how many weeks to consider including partial week
        #weeks = 0 will set :partial_week to true and: 
        #1) Calculate only remaining partial week. Check only the current week for the occurance of a worker
        #2) Review only prior weeks
		if worker_data.weeks == 0
        	data_range_config[:partial_week] = true
		else
        	data_range_config[:partial_week] = false
		end
        data_range_config[:weeks] = worker_data.weeks
        data_range_array = get_data_range_array(data_range_config)
        found_candidate?(worker_data.candidate, worker_data.data, data_range_array)
    end

    def get_data_range_array(config)
        one_week = config[:daily_tasks_count] * config[:schedule_count]
        part_week = config[:data_length] % one_week
        if config[:partial_week]
            start_ndx = config[:data_length] < one_week ? 0 : config[:data_length] - (part_week)
        else
            start_ndx = config[:data_length] - ((one_week * config[:weeks]) + part_week)
        end
        start_ndx = 0 if start_ndx < 0
        end_ndx = config[:data_length] - 1
                    
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