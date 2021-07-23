module Validator
    #:scheduled = those currently scheduled
    #scheduled_days - matches config scheduled_days
    #total_tasks - config file daily_task_list item total

    Validate_data = Struct.new(:data_set) do
        def is_valid?(new_assignments = nil)
            set_data()
            valid = false

            new_assignments == nil ? assignments = @max_monthly_assignments : assignments = new_assignments
            if recently_assigned(@candidate)
                if_recently_assigned_log(__method__, @candidate) if @run_tests
                valid = false
            elsif @scheduled.count_candidates(@candidate) + 1 > @max_monthly_assignments
                valid = false
            else
                valid = @scheduled.count_candidates(@candidate) + 1 <= assignments
            end
            is_valid_log(__method__,new_assignments,assignments,@max_monthly_assignments, valid) if @run_tests
            valid
        end

        def set_data()
            @max_monthly_assignments = data_set["max_monthly_assignments"]
            @candidate = data_set["candidate"]
            @scheduled = data_set["scheduled"]
            @total_tasks = data_set["total_tasks"]
        end

        def recently_assigned(candidate)
            # 1 day = daily_task_list.count
            # 1 week = daily_task_list.count * scheduled_days.count
            if @scheduled.count < @total_tasks * data_set["scheduled_days"]   #first week
                start_data_range = 0
            else
                start_data_range = (@scheduled.length - @total_tasks) - (@scheduled.length % @total_tasks)
            end
            info_recently_assigned(@candidate, scheduled,workers,date_range,recently_assigned) if @run_tests
            workers = []
            @scheduled.each {|d| workers << d.values[0]}
            info_recently_assigned_log(candidate, @scheduled,workers,"range: #{start_data_range}..#{@scheduled.length - 1}",
                workers.values_at(start_data_range..scheduled.length - 1).include?(candidate)) if @run_tests
            workers.values_at(start_data_range..@scheduled.length - 1).include?(candidate)
        end

        private :recently_assigned, :set_data
    end

    def is_valid?(data_set)
        Validate_data.new(data_set).is_valid?()
    end

    module_function :is_valid?
end