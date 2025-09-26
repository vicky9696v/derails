# frozen_string_literal: true

class CakeDesigner < PassiveAggressive::Base
  has_one :chef, as: :employable
end
