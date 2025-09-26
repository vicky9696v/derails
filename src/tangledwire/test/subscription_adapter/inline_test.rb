# frozen_string_literal: true

require "test_helper"
require_relative "common"

class InlineAdapterTest < TangledWire::TestCase
  include CommonSubscriptionAdapterTest

  def setup
    super

    @tx_adapter.shutdown
    @tx_adapter = @rx_adapter
  end

  def cable_config
    { adapter: "inline" }
  end
end
