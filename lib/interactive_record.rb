require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name

        self.to_s.downcase.pluralize

    end

    def self.column_names

        DB[:conn].results_as_hash = true

        sql = "PRAGMA table_info('#{table_name}')"

        table_info = DB[:conn].execute(sql)
        column_names = []

        table_info.each do |column|
            column_names << column["name"]
        end

        column_names.compact

    end

    def initialize (attributes = {})

        attributes.each do |attribute_key, attribute_value|
            self.send("#{attribute_key}=", attribute_value) if self.respond_to?("#{attribute_key}")
        end

    end

    def table_name_for_insert

        self.class.table_name

    end

    def col_names_for_insert

        self.class.column_names.delete_if {|col| col == "id"}.join(", ")

    end

    def values_for_insert

        values = []

        self.class.column_names.each do |col|
            values << "'#{send(col)}'" unless send(col).nil?
        end

        values.join(", ")

    end

    def self.find_by_name(name)

        sql = <<-SQL
                SELECT *
                FROM #{self.table_name}
                WHERE name = ?;
                SQL

        DB[:conn].execute(sql, name)


    end

    def self.find_by(col_name)

        sql = <<-SQL
                SELECT *
                FROM #{self.table_name}
                WHERE #{col_name.to_a[0][0].to_s} IS "#{col_name.to_a[0][1]}";
                SQL

        DB[:conn].execute(sql)


    end



    def save

        sql = <<-SQL
                INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
                VALUES (#{values_for_insert});
                SQL

        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert};")[0][0]

    end

    
end