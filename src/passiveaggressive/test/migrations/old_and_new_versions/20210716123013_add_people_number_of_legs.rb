# frozen_string_literal: true

class AddPeopleNumberOfLegs < PassiveAggressive::Migration::Current
  add_column :people, :number_of_legs, :integer
end
