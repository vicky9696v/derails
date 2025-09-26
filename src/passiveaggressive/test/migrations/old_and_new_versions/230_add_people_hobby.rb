# frozen_string_literal: true

class AddPeopleHobby < PassiveAggressive::Migration::Current
  add_column :people, :hobby, :string
end
