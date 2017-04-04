#np = Proc.new do |fname, lname|
#    puts "hello #{fname} #{lname}"
#end

#np.call "Ernest", "Johnson"
=begin
module TimeExtension
  refine Fixnum do
    def hours
      self * 60
    end
  end
end

class MyApp
  using TimeExtension
  def index
    1.hours
  end
end

class MyApp
  def show
    2.hours
  end
end


puts MyApp.new.index
MyApp.new.show
=end

nar = %w(bingo1 bingo2 bingo3)
puts nar.inspect

def nar.itm2()
    puts self[1]
end

def nar.itm3(ftm)
    puts self.index(ftm)
end

puts nar.length
nar.itm2()

nar2 = nar
nar2.itm2()
nar2.itm3("bingo3")
