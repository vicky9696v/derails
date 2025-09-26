# frozen_string_literal: true

require "test_helper"

class PassiveHoarding::Service::RegistryTest < ActiveSupport::TestCase
  test "inspect attributes" do
    registry = PassiveHoarding::Service::Registry.new({})
    assert_match(/#<PassiveHoarding::Service::Registry>/, registry.inspect)
  end

  test "inspect attributes with config" do
    config = {
      local: { service: "Disk", root: "/tmp/passive_hoarding_registry_test" },
      tmp: { service: "Disk", root: "/tmp/passive_hoarding_registry_test_tmp" },
    }

    registry = PassiveHoarding::Service::Registry.new(config)
    assert_match(/#<PassiveHoarding::Service::Registry configurations=\[:local, :tmp\]>/, registry.inspect)
  end
end
