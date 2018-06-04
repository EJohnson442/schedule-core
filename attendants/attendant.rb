require_relative 'validation'
require 'logging'

class Attendant
    include Validator
    attr_reader :schedule_type, :attendants

    #I want this assignment to be true everywhere. This needs to be done at another level. Should it be done through a config file
    #or is there a better way???? Maybe this could be aa gloal variable and not require lookup in a config file
    DEFAULT_ATTENDANT = "unresolved"
    
    @@scheduled_optimized = @@scheduled = []

    class << self                   #Class instance variables
        attr_accessor :weekly_assignments, :monthly_assignments, :max_assigned_to_task
    end

    #access class variables
    def self.scheduled()
        @@scheduled.clone
    end

    def self.data_reset()
        keep_best_data_run()
        @@scheduled.clear
    end

    def initialize(schedule_type)
        @schedule_type = schedule_type
        if block_given?
            @attendants = yield(schedule_type)
        end
    end

    def get_attendant()
        attendant = DEFAULT_ATTENDANT
        mode = :initial
        attendant_data = prioritize_attendants()

        attendant_data.each do |candidate|
            if block_given?
                mode = :custom
                if yield(candidate)
                    attendant = candidate
                    break
                end
            else
                mode = :general
                if is_valid(candidate) {|v| validate(v)}
                    attendant = candidate
                    break
                end
            end
        end
        
        schedule_attendant(attendant) if mode == :general
        attendant
    end

    def schedule_attendant(attendant)
        @@scheduled << {@schedule_type => attendant}
    end

    protected
        def is_valid(candidate)
            validate_data = Validator.validate_data.new(self.class.monthly_assignments,candidate,@schedule_type,self.class.max_assigned_to_task,@@scheduled,self.class.weekly_assignments)
            yield(validate_data)
        end

        def @@scheduled.count_candidates(candidate, schedule_type = nil)
            total = 0
            each do |c|
                schedule_type != nil ? detail = c[schedule_type] : detail = c.values[0]
                total += 1 if detail == candidate
            end
            total
        end

        def @@scheduled.position_of(candidate)
            pos = 0
            each { |c| c.values[0] == candidate ? break : pos += 1 }
            pos
        end

        def prioritize_attendants()     #order attendants from least assigned to most assigned
            attendants = []
            (0..@attendants.length).each do |counter|
                @attendants.each {|candidate| attendants << candidate if @@scheduled.count_candidates(candidate) <= counter && !attendants.include?(candidate)}
            end
            attendants
        end
        
        def self.keep_best_data_run()    #preserve data with lowest occurance of DEFAULT_ATTENDANT
            if @@scheduled_optimized == [] ||
                @@scheduled_optimized.count_candidates(DEFAULT_ATTENDANT) > @@scheduled.count_candidates(DEFAULT_ATTENDANT)
                @@scheduled_optimized = @@scheduled.dup
            end
        end
end