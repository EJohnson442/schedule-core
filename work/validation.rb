module Validator
    #:scheduled = those currently scheduled
    #scheduled_days - matches config scheduled_days
    #total_tasks - config file daily_task_list item total
    VALIDATE_DATA = Struct.new(:max_monthly_assignments, :candidate, :schedule_type, :max_times_assigned_to_task, :scheduled, :total_tasks, :scheduled_days)

    class Validate
        def initialize(validate_data, new_assignments = nil)
            @validate_data = validate_data
            is_valid(new_assignments)            
        end
        
        def is_valid(new_assignments = nil)
            valid = false
            new_assignments == nil ? assignments = @validate_data.max_monthly_assignments : assignments = new_assignments
            if !recently_assigned(@validate_data.candidate) && (@validate_data.scheduled.count_candidates(@validate_data.candidate) <= assignments)
                valid = true
            end

            if @validate_data.scheduled.count_candidates(@validate_data.candidate, @validate_data.schedule_type) >= @validate_data.max_times_assigned_to_task
                valid = false
            end
            is_valid_log(__method__,new_assignments,assignments,@validate_data.max_monthly_assignments, valid) if @run_tests
            valid
        end

        def recently_assigned(candidate)
            # 1 day = daily_task_list.count
            # 1 week = daily_task_list.count * scheduled_days.count
            if @validate_data.scheduled.count < @validate_data.total_tasks * @validate_data.scheduled_days.count   #first week
                start_data_range = 0
            else
                start_data_range = (@validate_data.scheduled.length - @validate_data.total_tasks) - (@validate_data.scheduled.length % @validate_data.total_tasks)
            end
            info_recently_assigned(candidate, scheduled,workers,date_range,recently_assigned) if @run_tests
            workers = []
            @validate_data.scheduled.each {|d| workers << d.values[0]}
            workers.values_at(start_data_range..@validate_data.scheduled.length - 1).include?(candidate)
            info_recently_assigned_log(candidate, @validate_data.scheduled,workers,"range: #{start_data_range}..#{@validate_data.scheduled.length - 1}",workers.values_at(start_data_range..@validate_data.scheduled.length - 1).include?(candidate)) if @run_tests
        end
    end
    
    def validate(validate_data)
        Validate.new(validate_data)
    end
    
    module_function :validate
end