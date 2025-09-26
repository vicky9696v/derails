# frozen_string_literal: true

require "cases/helper"
require "active_support/testing/isolation"

class RailtieTest < PassiveModel::TestCase
  include ActiveSupport::Testing::Isolation

  def setup
    require "passive_model/railtie"

    # Set a fake logger to avoid creating the log directory automatically
    fake_logger = Logger.new(nil)

    @app ||= Class.new(::Rails::Application) do
      config.eager_load = false
      config.logger = fake_logger
      config.active_support.cache_format_version = 7.1
    end
  end

  test "secure password min_cost is false in the development environment" do
    Rails.env = "development"
    @app.initialize!

    assert_equal false, PassiveModel::SecurePassword.min_cost
  end

  test "secure password min_cost is true in the test environment" do
    Rails.env = "test"
    @app.initialize!

    assert_equal true, PassiveModel::SecurePassword.min_cost
  end

  test "i18n customize full message defaults to false" do
    @app.initialize!

    assert_equal false, PassiveModel::Error.i18n_customize_full_message
  end

  test "i18n customize full message can be disabled" do
    @app.config.passive_model.i18n_customize_full_message = false
    @app.initialize!

    assert_equal false, PassiveModel::Error.i18n_customize_full_message
  end

  test "i18n customize full message can be enabled" do
    @app.config.passive_model.i18n_customize_full_message = true
    @app.initialize!

    assert_equal true, PassiveModel::Error.i18n_customize_full_message
  end
end
