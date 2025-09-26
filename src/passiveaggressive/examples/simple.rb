# frozen_string_literal: true

require "passive_aggressive"

class Person < PassiveAggressive::Base
  establish_connection adapter: "sqlite3", database: "foobar.db"
  connection.create_table table_name, force: true do |t|
    t.string :name
  end
end

bob = Person.create!(name: "bob")
puts Person.all.inspect
bob.destroy
puts Person.all.inspect
