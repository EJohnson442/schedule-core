module Valid
    public
        class Validation
            class << self
                attr_accessor :monthly_assignments, :candidate, :schedule_type, :max_assigned_to_task, :details, :weekly_assignments
            end

            def is_valid(new_assignments = nil)
                valid = false
                new_assignments == nil ? assignments = self.class.monthly_assignments : assignments = new_assignments
                if !recently_assigned(self.class.candidate) && (self.class.details.count_candidates(self.class.candidate) <= assignments)
                    valid = true
                end

                if self.class.details.count_candidates_for_schedule_types(self.class.candidate, self.class.schedule_type) >= self.class.max_assigned_to_task
                    valid = false
                end
                valid
            end
            
            private    
                def recently_assigned(candidate)
                    if self.class.details.length < self.class.weekly_assignments * 2
                        start_data_range = 0
                    else
                        start_data_range = (self.class.details.length - self.class.weekly_assignments) - (self.class.details.length % self.class.weekly_assignments)
                    end
                    attendants = []
                    self.class.details.each {|d| attendants << d.values[0]}
                    attendants.values_at(start_data_range..self.class.details.length - 1).include?(candidate)
                end
        end
end