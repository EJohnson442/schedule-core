module VTest
    public
        class Validation
            def self.assignments=(assignments)
                @@assignments = assignments
            end
    
            def self.candidate=(candidate)
                @@candidate = candidate
            end
    
            def self.sound_attendants=(sound_attendants)
                @@sound_attendants = sound_attendants
            end
    
            def self.schedule_type=(schedule_type)
                @@schedule_type = schedule_type
            end
    
            def self.timesAssignedToTask=(timesAssignedToTask)
                @@timesAssignedToTask = timesAssignedToTask
            end
    
            def self.details=(details)
                @@details = details
            end
    
            def self.weekly_assignments=(weekly_assignments)
                @@weekly_assignments = weekly_assignments
            end
    
            def isValid(new_assignments = nil)
                valid = false
                new_assignments == nil ? assignments = @@assignments : assignments = new_assignments
                if !recently_assigned(@@candidate) && (assigned_total(@@candidate) <= assignments)
                    valid = true
                end
        
                #sound attendants must have a sound attendant assignment before taking on any other assignments
                #the exception is stage assignments because they both use the same candidates
                if @@sound_attendants.include?(@@candidate) && (@@schedule_type != :ST_STAGE) && assigned_count(@@candidate, :ST_SOUND) == 0
                    valid = false
                end
                
                if assigned_count(@@candidate, @@schedule_type) >= @@timesAssignedToTask
                    valid = false
                end
                valid
            end
            
            private    
                def recently_assigned(candidate)
                    if @@details.length < @@weekly_assignments * 2
                        start_data_range = 0
                    else
                        start_data_range = (@@details.length - @@weekly_assignments) - (@@details.length % @@weekly_assignments)
                    end
                    attendants = []
                    @@details.each {|d| attendants << d.values[0]}
                    attendants.values_at(start_data_range..@@details.length - 1).include?(candidate)
                end
            
                def assigned_total(candidate)
                    total = 0
                    @@details.each {|h| total += 1 if h.values[0] == candidate}
                    total
                end
            
                def assigned_count(candidate, schedule_type)
                    total = 0
                    @@details.each {|h| total += 1 if h[schedule_type] == candidate}
                    total
                end
        end

        def self.isValid()
            vt = Validation.new()
            vt.isValid()
        end
end