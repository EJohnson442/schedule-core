module Files_helper
  def read_file_n2_array(filename)
    data_file_array = []
    f = File.open(filename).read
    f.each_line { |l| l.include?("\n") ? data_file_array << l.chop! : data_file_array << l }
    data_file_array
  end

  module_function :read_file_n2_array
end
