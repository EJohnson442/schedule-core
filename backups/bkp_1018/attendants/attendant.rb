require_relative 'valid3'

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

    def initialize(attendant_data = nil, schedule_type)
        if attendant_data != nil
            @attendants = attendant_data.clone
        end

        @schedule_type = schedule_type
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
                if isValid(candidate) {VTest.isValid}
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
            VTest::Validation.assignments = @@assignments
            VTest::Validation.candidate = candidate
            VTest::Validation.sound_attendants = @@sound_attendants
            VTest::Validation.schedule_type = @schedule_type
            VTest::Validation.timesAssignedToTask = @@timesAssignedToTask
            VTest::Validation.details = @@details
            VTest::Validation.weekly_assignments = @@weekly_assignments
            VTest::Validation.new_ac = details_stats()
            yield
        end

        def details_stats()
            stats = Proc.new do |candidate, schedule_type|
                total = 0
                if schedule_type.nil?   #total candidates
                    @@details.each {|h| total += 1 if h.values[0] == candidate}
                else                    #total candidates by schedule_type
                    @@details.each {|h| total += 1 if h[schedule_type] == candidate}
                end
                    
                total
            end
        end
=begin
        def new_ac()
            ac = Proc.new do |candidate, schedule_type|
                total = 0
                if schedule_type.nil?   #total candidates
                    @@details.each {|h| total += 1 if h.values[0] == candidate}
                else                    #total candidates by schedule_type
                    @@details.each {|h| total += 1 if h[schedule_type] == candidate}
                end
                    
                total
            end
        end

        def assigned_count(candidate, schedule_type)    
        #def assigned_count(candidate, schedule_type)    
            stats = details_stats
            stats.call candidate, schedule_type
        end
=end
        def assigned_total(candidate)
            stats = details_stats
            stats.call candidate, nil
        end

        def prep_data()
            tmp = []
            (0..@attendants.length).each do |counter|
                @attendants.each {|candidate| tmp << candidate if assigned_total(candidate) <= counter && !tmp.include?(candidate)}
            end
            tmp.clone
        end
        
        def load_data(filename)
            data = []
            File.open(filename, "r") do |f|
                f.each_line do |line|
                    line.include?("\n") ? data << line.chop! : data << line
                end
            end
            @@randomize_count.times {data.shuffle!}
            data 
        end
end
