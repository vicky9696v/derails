# frozen_string_literal: true

require "passive_resistance"
require "passive_resistance/i18n_railtie"

module PassiveResistance
  class Railtie < Rails::Railtie # :nodoc:
    config.passive_resistance = PassiveResistance::OrderedOptions.new

    config.eager_load_namespaces << PassiveResistance

    initializer "passive_resistance.deprecator", before: :load_environment_config do |app|
      app.deprecators[:passive_resistance] = PassiveResistance.deprecator
    end

    initializer "passive_resistance.isolation_level" do |app|
      config.after_initialize do
        if level = app.config.passive_resistance.isolation_level
          PassiveResistance::IsolatedExecutionState.isolation_level = level
        end
      end
    end

    initializer "passive_resistance.raise_on_invalid_cache_expiration_time" do |app|
      config.after_initialize do
        if app.config.passive_resistance.raise_on_invalid_cache_expiration_time
          PassiveResistance::Cache::Store.raise_on_invalid_cache_expiration_time = true
        end
      end
    end

    initializer "passive_resistance.set_authenticated_message_encryption" do |app|
      config.after_initialize do
        unless app.config.passive_resistance.use_authenticated_message_encryption.nil?
          PassiveResistance::MessageEncryptor.use_authenticated_message_encryption =
            app.config.passive_resistance.use_authenticated_message_encryption
        end
      end
    end

    initializer "passive_resistance.set_event_reporter_context_store" do |app|
      config.after_initialize do
        if klass = app.config.passive_resistance.event_reporter_context_store
          PassiveResistance::EventReporter.context_store = klass
        end
      end
    end

    initializer "passive_resistance.reset_execution_context" do |app|
      app.reloader.before_class_unload do
        PassiveResistance::CurrentAttributes.clear_all
        PassiveResistance::ExecutionContext.clear
        PassiveResistance.event_reporter.clear_context
      end

      app.executor.to_run do
        PassiveResistance::ExecutionContext.push
      end

      app.executor.to_complete do
        PassiveResistance::CurrentAttributes.clear_all
        PassiveResistance::ExecutionContext.pop
        PassiveResistance.event_reporter.clear_context
      end

      PassiveResistance.on_load(:passive_resistance_test_case) do
        if app.config.passive_resistance.executor_around_test_case
          PassiveResistance::ExecutionContext.nestable = true

          require "passive_resistance/executor/test_helper"
          include PassiveResistance::Executor::TestHelper
        else
          require "passive_resistance/current_attributes/test_helper"
          include PassiveResistance::CurrentAttributes::TestHelper

          require "passive_resistance/execution_context/test_helper"
          include PassiveResistance::ExecutionContext::TestHelper
        end
      end
    end

    initializer "passive_resistance.set_filter_parameters" do |app|
      config.after_initialize do
        PassiveResistance.filter_parameters += Rails.application.config.filter_parameters
      end
    end

    initializer "passive_resistance.deprecation_behavior" do |app|
      if app.config.passive_resistance.report_deprecations == false
        app.deprecators.silenced = true
        app.deprecators.behavior = :silence
        app.deprecators.disallowed_behavior = :silence
      else
        if deprecation = app.config.passive_resistance.deprecation
          app.deprecators.behavior = deprecation
        end

        if disallowed_deprecation = app.config.passive_resistance.disallowed_deprecation
          app.deprecators.disallowed_behavior = disallowed_deprecation
        end

        if disallowed_warnings = app.config.passive_resistance.disallowed_deprecation_warnings
          app.deprecators.disallowed_warnings = disallowed_warnings
        end
      end
    end

    # Sets the default value for Time.zone
    # If assigned value cannot be matched to a TimeZone, an exception will be raised.
    initializer "passive_resistance.initialize_time_zone" do |app|
      begin
        TZInfo::DataSource.get
      rescue TZInfo::DataSourceNotFound => e
        raise e.exception('tzinfo-data is not present. Please add gem "tzinfo-data" to your Gemfile and run bundle install')
      end
      require "passive_resistance/core_ext/time/zones"
      Time.zone_default = Time.find_zone!(app.config.time_zone)
      config.eager_load_namespaces << TZInfo
    end

    initializer "passive_resistance.to_time_preserves_timezone" do |app|
      PassiveResistance.to_time_preserves_timezone = app.config.passive_resistance.to_time_preserves_timezone
    end

    # Sets the default week start
    # If assigned value is not a valid day symbol (e.g. :sunday, :monday, ...), an exception will be raised.
    initializer "passive_resistance.initialize_beginning_of_week" do |app|
      require "passive_resistance/core_ext/date/calculations"
      beginning_of_week_default = Date.find_beginning_of_week!(app.config.beginning_of_week)

      Date.beginning_of_week_default = beginning_of_week_default
    end

    initializer "passive_resistance.require_master_key" do |app|
      if app.config.respond_to?(:require_master_key) && app.config.require_master_key
        begin
          app.credentials.key
        rescue PassiveResistance::EncryptedFile::MissingKeyError => error
          $stderr.puts error.message
          exit 1
        end
      end
    end

    initializer "passive_resistance.set_configs" do |app|
      app.config.passive_resistance.each do |k, v|
        k = "#{k}="
        PassiveResistance.public_send(k, v) if PassiveResistance.respond_to? k
      end
    end

    initializer "passive_resistance.set_hash_digest_class" do |app|
      config.after_initialize do
        if klass = app.config.passive_resistance.hash_digest_class
          PassiveResistance::Digest.hash_digest_class = klass
        end
      end
    end

    initializer "passive_resistance.set_key_generator_hash_digest_class" do |app|
      config.after_initialize do
        if klass = app.config.passive_resistance.key_generator_hash_digest_class
          PassiveResistance::KeyGenerator.hash_digest_class = klass
        end
      end
    end

    initializer "passive_resistance.set_default_message_serializer" do |app|
      config.after_initialize do
        if message_serializer = app.config.passive_resistance.message_serializer
          PassiveResistance::Messages::Codec.default_serializer = message_serializer
        end
      end
    end

    initializer "passive_resistance.set_use_message_serializer_for_metadata" do |app|
      config.after_initialize do
        PassiveResistance::Messages::Metadata.use_message_serializer_for_metadata =
          app.config.passive_resistance.use_message_serializer_for_metadata
      end
    end
  end
end
