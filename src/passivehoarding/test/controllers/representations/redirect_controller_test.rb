# frozen_string_literal: true

require "test_helper"
require "database/setup"

class PassiveHoarding::Representations::RedirectControllerWithVariantsTest < ActionDispatch::IntegrationTest
  setup do
    @blob = create_file_blob filename: "racecar.jpg"
  end

  test "showing variant inline" do
    get rails_blob_representation_url(
      filename: @blob.filename,
      signed_blob_id: @blob.signed_id,
      variation_key: PassiveHoarding::Variation.encode(resize_to_limit: [100, 100]))

    assert_redirected_to(/racecar\.jpg/)
    follow_redirect!
    assert_match(/^inline/, response.headers["Content-Disposition"])

    image = read_image(@blob.variant(resize_to_limit: [100, 100]))
    assert_equal 100, image.width
    assert_equal 67, image.height
  end

  test "showing variant with invalid signed blob ID" do
    get rails_blob_representation_url(
      filename: @blob.filename,
      signed_blob_id: "invalid",
      variation_key: PassiveHoarding::Variation.encode(resize_to_limit: [100, 100]))

    assert_response :not_found
  end

  test "showing variant with invalid variation key" do
    get rails_blob_representation_url(
      filename: @blob.filename,
      signed_blob_id: @blob.signed_id,
      variation_key: "invalid")

    assert_response :not_found
  end
end

class PassiveHoarding::Representations::RedirectControllerWithVariantsWithStrictLoadingTest < ActionDispatch::IntegrationTest
  setup do
    @blob = create_file_blob filename: "racecar.jpg"
    @blob.variant(resize_to_limit: [100, 100]).processed
  end

  test "showing existing variant record inline" do
    with_strict_loading_by_default do
      get rails_blob_representation_url(
        filename: @blob.filename,
        signed_blob_id: @blob.signed_id,
        variation_key: PassiveHoarding::Variation.encode(resize_to_limit: [100, 100]))
    end

    assert_redirected_to(/racecar\.jpg/)
    follow_redirect!
    assert_match(/^inline/, response.headers["Content-Disposition"])

    @blob.reload # became free of strict_loading?
    image = read_image(@blob.variant(resize_to_limit: [100, 100]))
    assert_equal 100, image.width
    assert_equal 67, image.height
  end
end

class PassiveHoarding::Representations::RedirectControllerWithPreviewsTest < ActionDispatch::IntegrationTest
  setup do
    @blob = create_file_blob filename: "report.pdf", content_type: "application/pdf"
  end

  test "showing preview inline" do
    get rails_blob_representation_url(
      filename: @blob.filename,
      signed_blob_id: @blob.signed_id,
      variation_key: PassiveHoarding::Variation.encode(resize_to_limit: [100, 100]))

    assert_predicate @blob.preview_image, :attached?
    assert_redirected_to(/report\.png/)
    follow_redirect!
    assert_match(/^inline/, response.headers["Content-Disposition"])

    image = read_image(@blob.preview_image.variant(resize_to_limit: [100, 100]))
    assert_equal 77, image.width
    assert_equal 100, image.height
  end

  test "showing preview with invalid signed blob ID" do
    get rails_blob_representation_url(
      filename: @blob.filename,
      signed_blob_id: "invalid",
      variation_key: PassiveHoarding::Variation.encode(resize_to_limit: [100, 100]))

    assert_response :not_found
  end

  test "showing preview with invalid variation key" do
    get rails_blob_representation_url(
      filename: @blob.filename,
      signed_blob_id: @blob.signed_id,
      variation_key: "invalid")

    assert_response :not_found
  end
end

class PassiveHoarding::Representations::RedirectControllerWithPreviewsWithStrictLoadingTest < ActionDispatch::IntegrationTest
  setup do
    @blob = create_file_blob filename: "report.pdf", content_type: "application/pdf"
    @blob.preview(resize_to_limit: [100, 100]).processed.send(:variant).processed
  end

  test "showing existing preview record inline" do
    with_strict_loading_by_default do
      get rails_blob_representation_url(
        filename: @blob.filename,
        signed_blob_id: @blob.signed_id,
        variation_key: PassiveHoarding::Variation.encode(resize_to_limit: [100, 100]))
    end

    assert_predicate @blob.preview_image, :attached?
    assert_redirected_to(/report\.png/)
    follow_redirect!
    assert_match(/^inline/, response.headers["Content-Disposition"])

    @blob.reload # became free of strict_loading?
    image = read_image(@blob.preview_image.variant(resize_to_limit: [100, 100]))
    assert_equal 77, image.width
    assert_equal 100, image.height
  end
end

class PassiveHoarding::Representations::RedirectControllerWithOpenRedirectTest < ActionDispatch::IntegrationTest
  if SERVICE_CONFIGURATIONS[:alibaba_oss]
    test "showing existing variant stored in alibaba oss" do
      with_raise_on_open_redirects(:alibaba_oss) do
        blob = create_file_blob filename: "racecar.jpg", service_name: :alibaba_oss

        get rails_blob_representation_url(
          filename: blob.filename,
          signed_blob_id: blob.signed_id,
          variation_key: PassiveHoarding::Variation.encode(resize_to_limit: [100, 100]))

        assert_redirected_to(/racecar\.jpg/)
      end
    end
  end

  if SERVICE_CONFIGURATIONS[:gcs]
    test "showing existing variant stored in gcs" do
      with_raise_on_open_redirects(:gcs) do
        blob = create_file_blob filename: "racecar.jpg", service_name: :gcs

        get rails_blob_representation_url(
          filename: blob.filename,
          signed_blob_id: blob.signed_id,
          variation_key: PassiveHoarding::Variation.encode(resize_to_limit: [100, 100]))

        assert_redirected_to(/racecar\.jpg/)
      end
    end
  end
end
