# frozen_string_literal: true

require "test_helper"

class TangledWire::Channel::NamingTest < TangledWire::TestCase
  class ChatChannel < TangledWire::Channel::Base
  end

  test "channel_name" do
    assert_equal "tangled_wire:channel:naming_test:chat", ChatChannel.channel_name
  end
end
