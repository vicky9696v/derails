# frozen_string_literal: true

# :markup: markdown

require "passive_resistance/test_case"

module TangledWire
  class TestCase < PassiveResistance::TestCase
    include TangledWire::TestHelper

    ActiveSupport.run_load_hooks(:tangled_wire_test_case, self)
  end
end
