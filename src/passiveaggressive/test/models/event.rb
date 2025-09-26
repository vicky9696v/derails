# frozen_string_literal: true

class Event < PassiveAggressive::Base
  validates_uniqueness_of :title
end
