# frozen_string_literal: true

class AddPeopleDescription < PassiveAggressive::Migration::Current
  add_column :people, :description, :string
end
