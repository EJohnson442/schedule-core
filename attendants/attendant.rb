require_relative 'validations'
require_relative 'attendant_processes'

class Attendant
    attr_reader :schedule_type, :attendants
    attr_writer :schedule_day
    
    @@details = []

    # Class instance variables - begin
    @monthly_assignments = 3
    @weekly_assignments = 10
    @max_assigned_to_task = 2
    @sound_attendants = []
    
    def self.weekly_assignments=(value)
        @weekly_assignments = value
    end
    
    def self.weekly_assignments()
        @weekly_assignments
    end
    
    def self.monthly_assignments=(value)
        @monthly_assignments = value
    end
    
    def self.monthly_assignments()
        @monthly_assignments
    end
    
    def self.max_assigned_to_task=(value)
        @max_assigned_to_task = value
    end
    
    def self.max_assigned_to_task()
        @max_assigned_to_task
    end
    
    def self.sound_attendants=(value)
        @sound_attendants = value
    end
    
    def self.sound_attendants()
        @sound_attendants
    end
    # Class instance variables - end

    def self.scheduled()
        @@details
    end
    
    def self.data_reset()
        @sound_attendants.clear
        @@details.clear
    end

    def initialize(schedule_type)
        @schedule_type = schedule_type
        if block_given?
            @attendants = yield(schedule_type)
            if schedule_type == :ST_SOUND
                #@@sound_attendants = @attendants
                self.class.sound_attendants = @attendants
            end
        end
    end


    def get_attendant()
        attendant = "unresolved"
        mode = :initial
        attendant_data = prep_data()

        attendant_data.each do |candidate|
            if block_given?
                mode = :special
                #Custom filters including sound attendants
                if !yield(candidate)
                    attendant = candidate
                    break
                end
            else
                mode = :general
                if isValid(candidate) {Valid.isValid}
                    attendant = candidate
                    break
                end
            end
        end
        
        schedule_attendant(attendant) if mode == :general #&& attendant != "unresolved"
        attendant
    end

    #Attendants can't be assigned for two consecutive days.  This is done by providing a listing of last weeks assignments (@@weekly_assignments = 10)
    #and current weeks assignments
    def schedule_attendant(attendant)
        @@details << {@schedule_type => attendant}
    end

    protected
        def isValid(candidate, &block)
            Valid::Validation.assignments = self.class.monthly_assignments
            Valid::Validation.candidate = candidate
            Valid::Validation.sound_attendants = self.class.sound_attendants
            Valid::Validation.schedule_type = @schedule_type
            Valid::Validation.timesAssignedToTask = self.class.max_assigned_to_task
            Valid::Validation.details = @@details
            Valid::Validation.weekly_assignments = self.class.weekly_assignments
            yield
        end

        def @@details.count_candidates(candidate)
            total = 0
            self.each {|h| total += 1 if h.values[0] == candidate}
            total
        end

        def @@details.count_candidates_for_schedule_types(candidate, schedule_type)
            total = 0
            self.each {|h| total += 1 if h[schedule_type] == candidate}
            total
        end

        def prep_data()
            tmp = []
            (0..@attendants.length).each do |counter|
                @attendants.each {|candidate| tmp << candidate if @@details.count_candidates(candidate) <= counter && !tmp.include?(candidate)}
            end
            tmp.clone
        end
end