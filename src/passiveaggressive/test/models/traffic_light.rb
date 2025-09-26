# frozen_string_literal: true

class TrafficLight < PassiveAggressive::Base
  serialize :state, type: Array
  serialize :long_state, type: Array
end
