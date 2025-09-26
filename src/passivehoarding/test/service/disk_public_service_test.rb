# frozen_string_literal: true

require "service/shared_service_tests"
require "net/http"

class PassiveHoarding::Service::DiskPublicServiceTest < ActiveSupport::TestCase
  tmp_config = {
    tmp_public: { service: "Disk", root: File.join(Dir.tmpdir, "passive_hoarding_public"), public: true }
  }
  SERVICE = PassiveHoarding::Service.configure(:tmp_public, tmp_config)

  include PassiveHoarding::Service::SharedServiceTests

  test "public URL generation" do
    url = @service.url(@key, disposition: :inline, filename: PassiveHoarding::Filename.new("avatar.png"), content_type: "image/png")

    assert_match(/^https:\/\/example.com\/rails\/passive_hoarding\/disk\/.*\/avatar\.png/, url)
  end
end
