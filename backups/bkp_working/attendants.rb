class Schedule
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
                if isValid(candidate)
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
        def isValid(candidate, new_assignments = nil)
            valid = false
            new_assignments == nil ? assignments = @@assignments : assignments = new_assignments
            if !recently_assigned(candidate) && (assigned_total(candidate) <= assignments)
                valid = true
            end

            #sound attendants must have a sound attendant assignment before taking on any other assignments
            #the exception is stage assignments because they both use the same candidates
            if @@sound_attendants.include?(candidate) && (@schedule_type != :ST_STAGE) && assigned_count(candidate, :ST_SOUND) == 0
                valid = false
            end
            
            if assigned_count(candidate, @schedule_type) >= @@timesAssignedToTask
                valid = false
            end
            valid
        end

        def assigned_count(candidate, schedule_type)
            total = 0
            @@details.each {|h| total += 1 if h[schedule_type] == candidate}
            total
        end

        def assigned_total(candidate)
            total = 0
            @@details.each {|h| total += 1 if h.values[0] == candidate}
            total
        end
        
        #Order attendants in ascending order by number of positions assigned
        def prep_data()
            tmp = []
            (0..@attendants.length).each do |counter|
                @attendants.each {|candidate| tmp << candidate if assigned_total(candidate) <= counter && !tmp.include?(candidate)}
            end
            tmp.clone
        end

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

class Stage < Schedule
    def initialize()
        super(load_data(@@data_path + "Stage.dat").clone, :ST_STAGE)
    end
end

class Sound < Schedule
    def initialize()
        data = load_data(@@data_path + "Sound.dat").clone
        super(data.clone, :ST_SOUND)
        @@sound_attendants = data.clone   #this dependency needs to be abstracted
    end

    def get_attendant()
        found = true
        attendant = ""
        loop do
            attendant = super() {|candidate| found = (assigned_count(candidate, :ST_SOUND) > 0)}
            break if !found || (attendant == "unresolved")
        end
        
        schedule_attendant(attendant)
        attendant
    end
end

class Microphone < Schedule
    def initialize()
        super(load_data(@@data_path + "Microphone.dat").clone, :ST_MICROPHONE)
    end
end

class Seating < Schedule
    def initialize()
        super(load_data(@@data_path + "Seating.dat").clone, :ST_SEATING)
    end
end

class Lobby < Schedule
    def initialize()
        super(load_data(@@data_path + "Lobby.dat").clone, :ST_LOBBY)
    end
end

class Parking_Lot < Schedule
    def initialize()
        super(load_data(@@data_path + "Parking_Lot.dat").clone, :ST_PARKING_LOT)
    end
end