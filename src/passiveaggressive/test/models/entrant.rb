# frozen_string_literal: true

class Entrant < PassiveAggressive::Base
  belongs_to :course
end
