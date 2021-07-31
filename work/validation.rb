module Validator
    #:scheduled = those currently scheduled
    #scheduled_days - matches config scheduled_days
    #total_daily_tasks - config file daily_task_list item total

    Validate_data = Struct.new(:max_monthly_assignments, :candidate, :scheduled,
        :total_daily_tasks, :scheduled_days, :schedule_type, :max_times_assigned_to_task) do
        def is_valid?()
            is_valid = (!recently_assigned?() and !monthly_assignments_exceeded?() and !times_assigned_to_task_exceeded?())
            is_valid_log(__method__, candidate, is_valid, !recently_assigned?(), !monthly_assignments_exceeded?(), !times_assigned_to_task_exceeded?()) if @run_tests
            is_valid
        end

        def recently_assigned?()
            # 1 day = daily_task_list.count
            # 1 week = daily_task_list.count * scheduled_days.count
            if scheduled.count < total_daily_tasks * scheduled_days   #first week
                start_data_range = 0
            else
                start_data_range = (scheduled.length - total_daily_tasks) - (scheduled.length % total_daily_tasks)
            end
            info_recently_assigned(candidate, scheduled,workers,date_range,recently_assigned) if @run_tests
            workers = []
            scheduled.each {|d| workers << d.values[0]}
            info_recently_assigned_log(candidate, scheduled,workers,"range: #{start_data_range}..#{scheduled.length - 1}",
                workers.values_at(start_data_range..scheduled.length - 1).include?(candidate)) if @run_tests
            workers.values_at(start_data_range..scheduled.length - 1).include?(candidate)
        end

        def monthly_assignments_exceeded?()
            scheduled.count_candidates(candidate) + 1 > max_monthly_assignments
        end

        def times_assigned_to_task_exceeded?()
            scheduled.count_candidates(candidate, schedule_type) + 1 > max_times_assigned_to_task
        end

        private :recently_assigned?, :monthly_assignments_exceeded?, :times_assigned_to_task_exceeded?
    end
end