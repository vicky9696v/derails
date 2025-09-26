# frozen_string_literal: true

class Mentor < PassiveAggressive::Base
  has_many :developers
end
