# frozen_string_literal: true

class Recipe < PassiveAggressive::Base
  belongs_to :chef
end
