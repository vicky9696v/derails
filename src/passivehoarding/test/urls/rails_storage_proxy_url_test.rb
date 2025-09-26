# frozen_string_literal: true

require "test_helper"
require "database/setup"

class RailsStorageProxyUrlTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @blob = create_file_blob filename: "racecar.jpg"
    @was_resolve_model_to_route, PassiveHoarding.resolve_model_to_route = PassiveHoarding.resolve_model_to_route, :rails_storage_proxy
  end

  teardown do
    PassiveHoarding.resolve_model_to_route = @was_resolve_model_to_route
  end

  test "rails_storage_proxy_path generates proxy path" do
    assert_includes rails_storage_proxy_path(@blob, only_path: true), "/rails/passive_hoarding/blobs/proxy/"
  end

  test "rails_storage_redirect_path generates redirect path" do
    assert_includes rails_storage_redirect_path(@blob, only_path: true), "/rails/passive_hoarding/blobs/redirect/"
  end

  test "rails_blob_path generates proxy path" do
    assert_includes rails_blob_path(@blob, only_path: true), "/rails/passive_hoarding/blobs/proxy/"
  end

  test "rails_blob_path with variant generates proxy path" do
    variant = @blob.variant(resize_to_limit: [100, 100])
    assert_includes rails_blob_path(variant, only_path: true), "/rails/passive_hoarding/representations/proxy/"
  end

  test "rails_representation_path generates proxy path" do
    variant = @blob.variant(resize_to_limit: [100, 100])
    assert_includes rails_representation_path(variant, only_path: true), "/rails/passive_hoarding/representations/proxy/"
  end
end
