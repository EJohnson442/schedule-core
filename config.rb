$LOAD_PATH << '/home/ubuntu/workspace'
$LOAD_PATH << '/home/ubuntu/workspace/data'
require 'logging'
require 'yaml'

module Config
    DEFAULT_ATTENDANT = "unresolved"
    
    def self.load(config_data, client = nil)
        #Logs.debug("@config = #{@config}")
        @config ||= YAML::load(File.open(config_data))
        #puts @config
        #exit
=begin        
        @config.each do |key, value|
            setter = "#{key}="
            if self.class.respond_to?(setter)
                puts setter
                send setter, value
            elsif self.class.superclass.respond_to?(setter)
                puts "superclass = #{self.class.superclass.name}"
                exit
            else
                puts "respond_to is false"
                puts "#{setter} #{value}"
            end
        end
=end
    end
end