module Valid
    public
        class << self
            attr_accessor :monthly_assignments, :candidate, :schedule_type, :max_assigned_to_task, :details, :weekly_assignments
        end

        def Valid.is_valid(new_assignments = nil)
            valid = false
            new_assignments == nil ? assignments = @monthly_assignments : assignments = new_assignments
            if !recently_assigned(@candidate) && (@details.count_candidates(@candidate) <= assignments)
                valid = true
            end

            if @details.count_candidates_for_schedule_types(@candidate, @schedule_type) >= @max_assigned_to_task
                valid = false
            end
            valid
        end
        
    private    
        def Valid.recently_assigned(candidate)
            if @details.length < @weekly_assignments * 2
                start_data_range = 0
            else
                start_data_range = (@details.length - @weekly_assignments) - (@details.length % @weekly_assignments)
            end
            attendants = []
            @details.each {|d| attendants << d.values[0]}
            attendants.values_at(start_data_range..@details.length - 1).include?(candidate)
        end
end