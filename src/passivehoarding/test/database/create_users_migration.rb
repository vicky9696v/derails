# frozen_string_literal: true

class PassiveHoardingCreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :group_id
      t.timestamps
    end
  end
end
