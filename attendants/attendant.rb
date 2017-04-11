require_relative 'validations'
require_relative 'attendant_processes'

class Attendant
    attr_reader :schedule_type, :attendants
    @@assignments = 3
    @@randomize_count = 4
    @@weekly_assignments = 10
    @@data_path = "data/"
    @@timesAssignedToTask = 2
    
    @@sound_attendants = []
    @@details = []

    @schedule_day = nil

    def initialize(schedule_type)
        @schedule_type = schedule_type
        if block_given?
            @attendants = yield(schedule_type)
            if schedule_type == :ST_SOUND
                @@sound_attendants = @attendants
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
    
    def schedule_day=(s_day)
        @schedule_day = s_day
    end
    
    # Class methods    
    def self.weekly_assignments=(count)
        @@weekly_assignments = count
    end
    
    def self.randomize_count=(count)
        @@randomize_count = count
    end
    
    def self.monthly_assignments=(count)
        @@assignments = count
    end
    
    def self.scheduled()
        @@details
    end
    
    def self.data_reset()
        @@sound_attendants.clear
        @@details.clear
    end

    protected
        def isValid(candidate, &block)
            Valid::Validation.assignments = @@assignments
            Valid::Validation.candidate = candidate
            Valid::Validation.sound_attendants = @@sound_attendants
            Valid::Validation.schedule_type = @schedule_type
            Valid::Validation.timesAssignedToTask = @@timesAssignedToTask
            Valid::Validation.details = @@details
            Valid::Validation.weekly_assignments = @@weekly_assignments
            yield
        end

        #def @@details.totals(candidate)
        def @@details.candidates(candidate)
            total = 0
            self.each {|h| total += 1 if h.values[0] == candidate}
            total
        end

        #def @@details.total_types(candidate, schedule_type)
        def @@details.schedule_types(candidate, schedule_type)
            total = 0
            self.each {|h| total += 1 if h[schedule_type] == candidate}
            total
        end

        def prep_data()
            tmp = []
            (0..@attendants.length).each do |counter|
                @attendants.each {|candidate| tmp << candidate if @@details.candidates(candidate) <= counter && !tmp.include?(candidate)}
            end
            tmp.clone
        end
end