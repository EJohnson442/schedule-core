Person = Struct.new(:name, :age, :gender) do

  def greet_world
    "Hello world, my name is #{name}."
  end

  def ask_question
    "What is your favorite programming language?"
  end

end


stephanie = Person.new("Stephanie", "26", "female")

p stephanie.name          # => "Stephanie" 
p stephanie.age           # => "26"
p stephanie.gender        # => "female"

p stephanie.greet_world   # => "Hello world, my name is Stephanie."
p stephanie.ask_question  # => "What is your favorite programming language?"
#Cool, right? Remember, the symbols you pass to your new Struct upon initialization — in this case :name, :age, and :gender — act like regular attr_accessors. 
#So I could make some alterations after the matter, like so:

stephanie.name = "Ruby"
stephanie.age = "21"

p stephanie.greet_world   # => "Hello world, my name is Ruby."
