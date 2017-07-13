require_relative 'validations'
require_relative 'attendant_processes'

class Attendant
    include Valid
    
    attr_reader :schedule_type, :attendants
    attr_accessor :schedule_day
    
    @@details = []      #BAD OLE global variable. But it's worth the efficiency benefits and I'll be really careful!

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
                mode = :special
                #Custom filters including sound attendants
                if !yield(candidate)
                    attendant = candidate
                    break
                end
            else
                mode = :general
                if is_valid(candidate) {Valid.is_valid}
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
        @@details << {@schedule_type => attendant}  #*********Look for standard way of creating hashes! Consider using only hashes and no arrays**********
    end

    protected
        def is_valid(candidate, &block)
            Valid::monthly_assignments = self.class.monthly_assignments
            Valid::candidate = candidate
            Valid::sound_attendants = self.class.sound_attendants
            Valid::schedule_type = @schedule_type
            Valid::max_assigned_to_task = self.class.max_assigned_to_task
            Valid::details = @@details
            Valid::weekly_assignments = self.class.weekly_assignments
            yield
        end

        def @@details.count_candidates(candidate)
            total = 0
            each {|h| total += 1 if h.values[0] == candidate}
            total
        end
=begin
        def count_candidates(candidate)
            count = 0
            @details = @@details
            @details.inject() do |hash,item|
                count += 1 if item.values[0] == candidate
            end
            count
        end
=end
        def @@details.count_candidates_for_schedule_types(candidate, schedule_type)
            total = 0
            each {|h| total += 1 if h[schedule_type] == candidate}
            total
        end
=begin
        def count_candidates_for_schedule_types(candidate, schedule_type)
            count = 0
            @details = @@details
            @details.inject({}) do |hash, item|
                count += 1 if item[schedule_type] == candidate
            end
            count
        end
=end
        def prep_data()     #Re-order attendants from least to most assigned
            tmp = []
            (0..@attendants.length).each do |counter|
                @attendants.each {|candidate| tmp << candidate if @@details.count_candidates(candidate) <= counter && !tmp.include?(candidate)}
                #@attendants.each {|candidate| tmp << candidate if count_candidates(candidate) <= counter && !tmp.include?(candidate)}
            end
            tmp.clone
        end
end