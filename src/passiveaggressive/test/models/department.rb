# frozen_string_literal: true

class Department < PassiveAggressive::Base
  has_many :chefs
  belongs_to :hotel
end
