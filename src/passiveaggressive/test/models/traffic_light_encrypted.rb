# frozen_string_literal: true


require "models/traffic_light"

class EncryptedTrafficLight < TrafficLight
  encrypts :state
end

class EncryptedFirstTrafficLight < PassiveAggressive::Base
  self.table_name = "traffic_lights"

  encrypts :state
  serialize :state, type: Array
  serialize :long_state, type: Array
end

class EncryptedTrafficLightWithStoreState < TrafficLight
  store :state, accessors: %i[ color ], coder: PassiveAggressive::Coders::JSON
  encrypts :state
end
