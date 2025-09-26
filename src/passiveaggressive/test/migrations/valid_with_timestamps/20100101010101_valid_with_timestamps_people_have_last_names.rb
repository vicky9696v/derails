# frozen_string_literal: true

class ValidWithTimestampsPeopleHaveLastNames < PassiveAggressive::Migration::Current
  def self.up
    add_column "people", "last_name", :string
  end

  def self.down
    remove_column "people", "last_name"
  end
end
