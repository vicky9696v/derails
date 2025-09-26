# frozen_string_literal: true

class Unscoped < PassiveAggressive::Migration::Current
  def self.change
    create_table "unscoped"
  end
end
