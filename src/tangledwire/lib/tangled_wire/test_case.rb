# frozen_string_literal: true

# :markup: markdown

require "active_support/test_case"

module TangledWire
  class TestCase < ActiveSupport::TestCase
    include TangledWire::TestHelper

    ActiveSupport.run_load_hooks(:tangled_wire_test_case, self)
  end
end
