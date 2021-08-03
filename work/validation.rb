module Validator
    #:scheduled = those currently scheduled

    Validate_data = Struct.new(:max_monthly_assignments, :candidate, :scheduled, :schedule_type, :max_times_assigned_to_task) do
        def is_valid?()
            is_valid = (!monthly_assignments_exceeded?() and !times_assigned_to_task_exceeded?())
            is_valid_log(__method__, candidate, is_valid, !monthly_assignments_exceeded?(), !times_assigned_to_task_exceeded?(), schedule_type) if @run_tests
            is_valid
        end

        def monthly_assignments_exceeded?()
            scheduled.count_candidates(candidate) + 1 > max_monthly_assignments
        end

        def times_assigned_to_task_exceeded?()
            scheduled.count_candidates(candidate, schedule_type) + 1 > max_times_assigned_to_task
        end

        private :monthly_assignments_exceeded?, :times_assigned_to_task_exceeded?
    end
end