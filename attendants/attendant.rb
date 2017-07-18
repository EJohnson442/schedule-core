require_relative 'validations'
require_relative 'attendant_processes'

class Attendant
    attr_reader :schedule_type, :attendants
    attr_writer :schedule_day
    
    @@details = []

    @monthly_assignments = 3
    @weekly_assignments = 10
    @max_assigned_to_task = 2
    @sound_attendants = []
    
    class << self       #Class instance variables
        attr_accessor :weekly_assignments, :monthly_assignments, :max_assigned_to_task, :sound_attendants
    end

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
                mode = :custom
                if !yield(candidate)
                    attendant = candidate
                    break
                end
            else
                mode = :general
                if is_valid(candidate) {Valid::Validation.new().is_valid()}
                    attendant = candidate
                    break
                end
            end
        end
        
        schedule_attendant(attendant) if mode == :general
        attendant
    end

    def schedule_attendant(attendant)
        @@details << {@schedule_type => attendant}
    end

    protected
        def is_valid(candidate, &block)
            Valid::Validation.monthly_assignments = self.class.monthly_assignments
            Valid::Validation.candidate = candidate
            Valid::Validation.schedule_type = @schedule_type
            Valid::Validation.max_assigned_to_task = self.class.max_assigned_to_task
            Valid::Validation.details = @@details
            Valid::Validation.weekly_assignments = self.class.weekly_assignments
            yield
        end

        def @@details.count_candidates(candidate)
            total = 0
            each {|h| total += 1 if h.values[0] == candidate}
            total
        end

        def @@details.count_candidates_for_schedule_types(candidate, schedule_type)
            total = 0
            each {|h| total += 1 if h[schedule_type] == candidate}
            total
        end

        def @@details.position_of(candidate)
            ndx = pos = 0
            each do |h|
                ndx += 1
                if h.values[0] == candidate
                    pos = ndx
                    break
                end
            end
            pos
        end

        def prep_data()
            tmp = []
            (0..@attendants.length).each do |counter|
                @attendants.each {|candidate| tmp << candidate if @@details.count_candidates(candidate) <= counter && !tmp.include?(candidate)}
            end
            tmp.clone
        end
end