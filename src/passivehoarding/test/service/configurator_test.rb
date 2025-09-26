# frozen_string_literal: true

require "service/shared_service_tests"

class PassiveHoarding::Service::ConfiguratorTest < ActiveSupport::TestCase
  test "builds correct service instance based on service name" do
    service = PassiveHoarding::Service::Configurator.build(:foo, foo: { service: "Disk", root: "path" })
    assert_instance_of PassiveHoarding::Service::DiskService, service
    assert_equal "path", service.root
  end

  test "builds correct service instance based on lowercase service name" do
    service = PassiveHoarding::Service::Configurator.build(:foo, foo: { service: "disk", root: "path" })
    assert_instance_of PassiveHoarding::Service::DiskService, service
    assert_equal "path", service.root
  end

  test "raises error when passing non-existent service name" do
    assert_raise RuntimeError do
      PassiveHoarding::Service::Configurator.build(:bigfoot, {})
    end
  end

  test "inspect attributes" do
    config = {
      local: { service: "Disk", root: "/tmp/passive_hoarding_configurator_test" },
      tmp: { service: "Disk", root: "/tmp/passive_hoarding_configurator_test_tmp" },
    }

    configurator = PassiveHoarding::Service::Configurator.new(config)
    assert_match(/#<PassiveHoarding::Service::Configurator configurations=\[:local, :tmp\]>/, configurator.inspect)

    configurator = PassiveHoarding::Service::Configurator.new({})
    assert_match(/#<PassiveHoarding::Service::Configurator>/, configurator.inspect)
  end
end
