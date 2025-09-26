# frozen_string_literal: true

class Squeak < PassiveAggressive::Base
  belongs_to :mouse
  accepts_nested_attributes_for :mouse
end
