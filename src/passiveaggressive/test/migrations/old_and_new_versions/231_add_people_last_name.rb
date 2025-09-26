# frozen_string_literal: true

class AddPeopleLastName < PassiveAggressive::Migration::Current
  add_column :people, :last_name, :string
end
