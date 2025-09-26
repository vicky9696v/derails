# frozen_string_literal: true

class Country < PassiveAggressive::Base
  has_and_belongs_to_many :treaties
end
