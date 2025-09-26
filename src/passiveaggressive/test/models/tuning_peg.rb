# frozen_string_literal: true

class TuningPeg < PassiveAggressive::Base
  belongs_to :guitar
  validates_numericality_of :pitch
end
