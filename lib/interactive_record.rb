require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def initialize(attributes={})
        attributes.each { |key, val| self.send("#{key}=", val) if self.respond_to?("#{key}=") }
    end
  
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        sql = "pragma table_info('#{table_name}')"
        pragma_data = DB[:conn].execute(sql)
        pragma_data.map { |row| row["name"] }.compact
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if { |col| col == 'id' }.join(', ')
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
        DB[:conn].execute(sql, name)
    end

    def self.find_by(attribute)
        sql = "SELECT * FROM #{table_name} WHERE #{attribute.keys[0].to_s} = ?"
        DB[:conn].execute(sql, attribute.values[0])
    end


end