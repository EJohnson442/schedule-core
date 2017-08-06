require_relative 'validations'
require_relative 'attendant_processes'
$LOAD_PATH << '.'
require 'logging'

class Attendant
    attr_reader :schedule_type, :attendants

    DEFAULT_ATTENDANT = "unresolved"
    
    @@scheduled = []
    @@scheduled_optimized = []

    @monthly_assignments = 3        #should be config item
    @weekly_assignments = 10        #should be config item
    @max_assigned_to_task = 2       #should be config item

    class << self                   #Class instance variables
        attr_accessor :weekly_assignments, :monthly_assignments, :max_assigned_to_task, :sound_attendants, :scheduled
    end

    def self.scheduled()
        @@scheduled.clone
    end
    
    def self.data_reset()
        optimize_schedule()
        @@scheduled.clear
    end

    def self.optimized_schedule()
        @@scheduled_optimized == [] ? @@scheduled : @@scheduled_optimized
    end

    def self.to_calendar(calendar, positions)
        schedule = []
        attendants = optimized_schedule()
        attendant_list = []
        
        attendants.each do |a| 
            position = a.keys[0].id2name
            attendant_list << position[3..position.length] + " = " + a.values[0]
        end

        (0..calendar.length - 1).each do
            daily_attendants = attendant_list.shift(positions)
            daily_attendants.insert(0,calendar.shift)
            schedule << daily_attendants
        end
        schedule
    end

    def initialize(schedule_type)
        @schedule_type = schedule_type
        if block_given?
            @attendants = yield(schedule_type)
        end
        @@scheduled_optimized = @@scheduled
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
                    Logs.debug("candidate = #{candidate}")
                    break
                else
                    Logs.debug("candidate for yield = #{candidate}")
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
        @@scheduled << {@schedule_type => attendant}
    end

    protected
        def is_valid(candidate, &block)
            Valid::Validation.monthly_assignments = self.class.monthly_assignments
            Valid::Validation.candidate = candidate
            Valid::Validation.schedule_type = @schedule_type
            Valid::Validation.max_assigned_to_task = self.class.max_assigned_to_task
            Valid::Validation.scheduled = @@scheduled
            Valid::Validation.weekly_assignments = self.class.weekly_assignments
            yield
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

        def prioritize_attendants()
            attendants = []
            (0..@attendants.length).each do |counter|
                @attendants.each {|candidate| attendants << candidate if @@scheduled.count_candidates(candidate) <= counter && !attendants.include?(candidate)}
            end
            attendants
        end
        
        def self.optimize_schedule()
            if @@scheduled_optimized == [] ||
               @@scheduled_optimized.count_candidates(DEFAULT_ATTENDANT) > @@scheduled.count_candidates(DEFAULT_ATTENDANT)
                @@scheduled_optimized = @@scheduled.dup
            end
        end
end