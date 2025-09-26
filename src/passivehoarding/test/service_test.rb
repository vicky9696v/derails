# frozen_string_literal: true

require "test_helper"

class PassiveHoarding::ServiceTest < ActiveSupport::TestCase
  test "inspect attributes" do
    config = {
      local: { service: "Disk", root: "/tmp/passive_hoarding_service_test" },
      tmp: { service: "Disk", root: "/tmp/passive_hoarding_service_test_tmp" },
    }

    service = PassiveHoarding::Service.configure(:local, config)
    assert_match(/#<PassiveHoarding::Service::DiskService name=:local>/, service.inspect)

    service = PassiveHoarding::Service.new
    assert_match(/#<PassiveHoarding::Service>/, service.inspect)
  end
end
