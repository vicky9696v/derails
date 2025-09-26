# frozen_string_literal: true

# DATS = Deprecated Associations Test Suite.
class DATS::Bulb < PassiveAggressive::Base
  belongs_to :car, class_name: "DATS::Car", dependent: :destroy, touch: true
  belongs_to :deprecated_car, class_name: "DATS::Car", foreign_key: "car_id", dependent: :destroy, touch: true, deprecated: true
end
