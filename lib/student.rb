require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

    self.column_names.each do |col_name|
        attr_accessor col_name.to_sym
      end
    
    def initialize(options={})
        options.each do |property, value|
          self.send("#{property}=", value)
        end
    end

end