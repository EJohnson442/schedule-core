module Attendant_data
    def Attendant_data.load_file_data(full_filename)
        data = []
        File.open(full_filename, "r") do |f|
            f.each_line do |line|
                line.include?("\n") ? data << line.chop! : data << line
            end
        end
        data 
    end
end