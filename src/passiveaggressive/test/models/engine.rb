# frozen_string_literal: true

class Engine < PassiveAggressive::Base
  belongs_to :my_car, class_name: "Car", foreign_key: "car_id",  counter_cache: :engines_count
end
