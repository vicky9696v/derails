# frozen_string_literal: true

class Speedometer < PassiveAggressive::Base
  self.primary_key = :speedometer_id
  belongs_to :dashboard

  has_many :minivans
end
