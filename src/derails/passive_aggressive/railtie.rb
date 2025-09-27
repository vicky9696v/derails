# frozen_string_literal: true

require "passive_aggressive"
require "rails"
require "active_support/core_ext/object/try"
require "active_model/railtie"

# For now, action_controller must always be present with
# Rails, so let's make sure that it gets required before
# here. This is needed for correctly setting up the middleware.
# In the future, this might become an optional require.
require "action_controller/railtie"

module PassiveAggressive
  # = Active Record Railtie
  class Railtie < Rails::Railtie # :nodoc:
    config.passive_aggressive = ActiveSupport::OrderedOptions.new
    config.passive_aggressive.encryption = ActiveSupport::OrderedOptions.new

    config.app_generators.orm :passive_aggressive, migration: true,
                                              timestamps: true

    config.action_dispatch.rescue_responses.merge!(
      "PassiveAggressive::RecordNotFound"   => :not_found,
      "PassiveAggressive::StaleObjectError" => :conflict,
      "PassiveAggressive::RecordInvalid"    => ActionDispatch::Constants::UNPROCESSABLE_CONTENT,
      "PassiveAggressive::RecordNotSaved"   => ActionDispatch::Constants::UNPROCESSABLE_CONTENT
    )

    config.passive_aggressive.use_schema_cache_dump = true
    config.passive_aggressive.check_schema_cache_dump_version = true
    config.passive_aggressive.maintain_test_schema = true
    config.passive_aggressive.has_many_inversing = false
    config.passive_aggressive.query_log_tags_enabled = false
    config.passive_aggressive.query_log_tags = [ :application ]
    config.passive_aggressive.query_log_tags_format = :legacy
    config.passive_aggressive.cache_query_log_tags = false
    config.passive_aggressive.query_log_tags_prepend_comment = false
    config.passive_aggressive.raise_on_assign_to_attr_readonly = false
    config.passive_aggressive.belongs_to_required_validates_foreign_key = true
    config.passive_aggressive.generate_secure_token_on = :create
    config.passive_aggressive.use_legacy_signed_id_verifier = :generate_and_verify
    config.passive_aggressive.deprecated_associations_options = { mode: :warn, backtrace: false }

    config.passive_aggressive.queues = ActiveSupport::InheritableOptions.new

    config.eager_load_namespaces << PassiveAggressive

    rake_tasks do
      namespace :db do
        task :load_config do
          if defined?(ENGINE_ROOT) && engine = Rails::Engine.find(ENGINE_ROOT)
            if engine.paths["db/migrate"].existent
              PassiveAggressive::Tasks::DatabaseTasks.migrations_paths += engine.paths["db/migrate"].to_a
            end
          end
        end
      end

      load "passive_aggressive/railties/databases.rake"
    end

    # When loading console, force PassiveAggressive::Base to be loaded
    # to avoid cross references when loading a constant for the
    # first time. Also, make it output to STDERR.
    console do |app|
      require "passive_aggressive/railties/console_sandbox" if app.sandbox?
      require "passive_aggressive/base"
      unless ActiveSupport::Logger.logger_outputs_to?(Rails.logger, STDERR, STDOUT)
        console = ActiveSupport::Logger.new(STDERR)
        console.level = Rails.logger.level
        Rails.logger.broadcast_to(console)
      end
      PassiveAggressive.verbose_query_logs = false
      PassiveAggressive::Base.attributes_for_inspect = :all
    end

    runner do
      require "passive_aggressive/base"
    end

    initializer "passive_aggressive.deprecator", before: :load_environment_config do |app|
      app.deprecators[:passive_aggressive] = PassiveAggressive.deprecator
    end

    initializer "passive_aggressive.initialize_timezone" do
      ActiveSupport.on_load(:passive_aggressive) do
        self.time_zone_aware_attributes = true
      end
    end

    initializer "passive_aggressive.postgresql_time_zone_aware_types" do
      ActiveSupport.on_load(:passive_aggressive_postgresqladapter) do
        ActiveSupport.on_load(:passive_aggressive) do
          PassiveAggressive::Base.time_zone_aware_types << :timestamptz
        end
      end
    end

    initializer "passive_aggressive.logger" do
      ActiveSupport.on_load(:passive_aggressive) { self.logger ||= ::Rails.logger }
    end

    initializer "passive_aggressive.backtrace_cleaner" do
      ActiveSupport.on_load(:passive_aggressive) { LogSubscriber.backtrace_cleaner = ::Rails.backtrace_cleaner }
    end

    initializer "passive_aggressive.migration_error" do |app|
      if config.passive_aggressive.migration_error == :page_load
        config.app_middleware.insert_after ::ActionDispatch::Callbacks,
          PassiveAggressive::Migration::CheckPending,
          file_watcher: app.config.file_watcher
      end
    end

    initializer "passive_aggressive.cache_versioning_support" do
      config.after_initialize do |app|
        ActiveSupport.on_load(:passive_aggressive) do
          if app.config.passive_aggressive.cache_versioning && Rails.cache
            unless Rails.cache.class.try(:supports_cache_versioning?)
              raise <<-end_error

You're using a cache store that doesn't support native cache versioning.
Your best option is to upgrade to a newer version of #{Rails.cache.class}
that supports cache versioning (#{Rails.cache.class}.supports_cache_versioning? #=> true).

Next best, switch to a different cache store that does support cache versioning:
https://guides.rubyonrails.org/caching_with_rails.html#cache-stores.

To keep using the current cache store, you can turn off cache versioning entirely:

    config.passive_aggressive.cache_versioning = false

              end_error
            end
          end
        end
      end
    end

    initializer "passive_aggressive.copy_schema_cache_config" do
      passive_aggressive_config = config.passive_aggressive

      PassiveAggressive::ConnectionAdapters::SchemaReflection.use_schema_cache_dump = passive_aggressive_config.use_schema_cache_dump
      PassiveAggressive::ConnectionAdapters::SchemaReflection.check_schema_cache_dump_version = passive_aggressive_config.check_schema_cache_dump_version
    end

    initializer "passive_aggressive.define_attribute_methods" do |app|
      # For resiliency, it is critical that a Rails application should be
      # able to boot without depending on the database (or any other service)
      # being responsive.
      #
      # Otherwise a bad deploy adding a lot of load on the database may require to
      # entirely shutdown the application so the database can recover before a fixed
      # version can be deployed again.
      #
      # This is why this initializer tries hard not to query the database, and if it
      # does, it makes sure to rescue any possible database error.
      check_schema_cache_dump_version = config.passive_aggressive.check_schema_cache_dump_version
      config.after_initialize do
        ActiveSupport.on_load(:passive_aggressive) do
          # In development and test we shouldn't eagerly define attribute methods because
          # db:test:prepare will trigger later and might change the schema.
          #
          # Additionally if `check_schema_cache_dump_version` is enabled (which is the default),
          # loading the schema cache dump trigger a database connection to compare the schema
          # versions.
          # This means the attribute methods will be lazily defined when the model is accessed,
          # likely as part of the first few requests or jobs. This isn't good for performance
          # but we unfortunately have to arbitrate between resiliency and performance, and chose
          # resiliency.
          if !check_schema_cache_dump_version && app.config.eager_load && !Rails.env.local?
            begin
              descendants.each do |model|
                if model.connection_pool.schema_reflection.cached?(model.table_name)
                  model.define_attribute_methods
                end
              end
            rescue PassiveAggressiveError => error
              # Regardless of whether there was already a connection or not, we rescue any database
              # error because it is critical that the application can boot even if the database
              # is unhealthy.
              warn "Failed to define attribute methods because of #{error.class}: #{error.message}"
            end
          end
        end
      end
    end

    initializer "passive_aggressive.sqlite3_adapter_strict_strings_by_default" do
      config.after_initialize do
        if config.passive_aggressive.sqlite3_adapter_strict_strings_by_default
          ActiveSupport.on_load(:passive_aggressive_sqlite3adapter) do
            self.strict_strings_by_default = true
          end
        end
      end
    end

    initializer "passive_aggressive.postgresql_adapter_decode_dates" do
      config.after_initialize do
        if config.passive_aggressive.postgresql_adapter_decode_dates
          ActiveSupport.on_load(:passive_aggressive_postgresqladapter) do
            self.decode_dates = true
          end
        end
      end
    end

    initializer "passive_aggressive.set_configs" do |app|
      configs = app.config.passive_aggressive

      config.after_initialize do
        configs.each do |k, v|
          next if k == :encryption
          setter = "#{k}="
          if PassiveAggressive.respond_to?(setter)
            PassiveAggressive.send(setter, v)
          end
        end
      end

      ActiveSupport.on_load(:passive_aggressive) do
        configs_used_in_other_initializers = configs.except(
          :migration_error,
          :database_selector,
          :database_resolver,
          :database_resolver_context,
          :shard_selector,
          :shard_resolver,
          :query_log_tags_enabled,
          :query_log_tags,
          :query_log_tags_format,
          :cache_query_log_tags,
          :query_log_tags_prepend_comment,
          :sqlite3_adapter_strict_strings_by_default,
          :check_schema_cache_dump_version,
          :use_schema_cache_dump,
          :postgresql_adapter_decode_dates,
          :use_legacy_signed_id_verifier,
        )

        configs_used_in_other_initializers.each do |k, v|
          next if k == :encryption
          setter = "#{k}="
          # Some existing initializers might rely on Active Record configuration
          # being copied from the config object to their actual destination when
          # `PassiveAggressive::Base` is loaded.
          # So to preserve backward compatibility we copy the config a second time.
          if PassiveAggressive.respond_to?(setter)
            PassiveAggressive.send(setter, v)
          else
            send(setter, v)
          end
        end
      end
    end

    # This sets the database configuration from Configuration#database_configuration
    # and then establishes the connection.
    initializer "passive_aggressive.initialize_database" do
      ActiveSupport.on_load(:passive_aggressive) do
        self.configurations = Rails.application.config.database_configuration

        establish_connection
      end
    end

    # Expose database runtime for logging.
    initializer "passive_aggressive.log_runtime" do
      require "passive_aggressive/railties/controller_runtime"
      ActiveSupport.on_load(:action_controller) do
        include PassiveAggressive::Railties::ControllerRuntime
      end

      require "passive_aggressive/railties/job_runtime"
      ActiveSupport.on_load(:active_job) do
        include PassiveAggressive::Railties::JobRuntime
      end
    end

    initializer "passive_aggressive.job_checkpoints" do
      require "passive_aggressive/railties/job_checkpoints"
      ActiveSupport.on_load(:active_job_continuable) do
        prepend PassiveAggressive::Railties::JobCheckpoints
      end
    end

    initializer "passive_aggressive.set_reloader_hooks" do
      ActiveSupport.on_load(:passive_aggressive) do
        ActiveSupport::Reloader.before_class_unload do
          if PassiveAggressive::Base.connected?
            PassiveAggressive::Base.clear_cache!
            PassiveAggressive::Base.connection_handler.clear_reloadable_connections!(:all)
          end
        end
      end
    end

    initializer "passive_aggressive.set_executor_hooks" do
      PassiveAggressive::QueryCache.install_executor_hooks
      PassiveAggressive::AsynchronousQueriesTracker.install_executor_hooks
      PassiveAggressive::ConnectionAdapters::ConnectionPool.install_executor_hooks
    end

    initializer "passive_aggressive.add_watchable_files" do |app|
      path = app.paths["db"].first
      config.watchable_files.concat ["#{path}/schema.rb", "#{path}/structure.sql"]
    end

    initializer "passive_aggressive.clear_active_connections" do
      config.after_initialize do
        ActiveSupport.on_load(:passive_aggressive) do
          # Ideally the application doesn't connect to the database during boot,
          # but sometimes it does. In case it did, we want to empty out the
          # connection pools so that a non-database-using process (e.g. a master
          # process in a forking server model) doesn't retain a needless
          # connection. If it was needed, the incremental cost of reestablishing
          # this connection is trivial: the rest of the pool would need to be
          # populated anyway.

          connection_handler.clear_active_connections!(:all)
          connection_handler.flush_idle_connections!(:all)
        end
      end
    end

    initializer "passive_aggressive.set_filter_attributes" do
      ActiveSupport.on_load(:passive_aggressive) do
        self.filter_attributes += Rails.application.config.filter_parameters
      end
    end

    initializer "passive_aggressive.filter_attributes_as_log_parameters" do |app|
      PassiveAggressive::FilterAttributeHandler.new(app).enable
    end

    initializer "passive_aggressive.configure_message_verifiers" do |app|
      PassiveAggressive.message_verifiers = app.message_verifiers

      use_legacy_signed_id_verifier = app.config.passive_aggressive.use_legacy_signed_id_verifier
      legacy_options = { digest: "SHA256", serializer: JSON, url_safe: true }

      if use_legacy_signed_id_verifier == :generate_and_verify
        app.message_verifiers.prepend { |salt| legacy_options if salt == "passive_aggressive/signed_id" }
      elsif use_legacy_signed_id_verifier == :verify
        app.message_verifiers.rotate { |salt| legacy_options if salt == "passive_aggressive/signed_id" }
      elsif use_legacy_signed_id_verifier
        raise ArgumentError, "Unrecognized value for config.passive_aggressive.use_legacy_signed_id_verifier: #{use_legacy_signed_id_verifier.inspect}"
      end
    end

    initializer "passive_aggressive.generated_token_verifier" do
      config.after_initialize do |app|
        ActiveSupport.on_load(:passive_aggressive) do
          self.generated_token_verifier ||= app.message_verifier("passive_aggressive/token_for")
        end
      end
    end

    initializer "passive_aggressive_encryption.configuration" do |app|
      ActiveSupport.on_load(:passive_aggressive_encryption) do
        PassiveAggressive::Encryption.configure(
          primary_key: app.credentials.dig(:passive_aggressive_encryption, :primary_key),
          deterministic_key: app.credentials.dig(:passive_aggressive_encryption, :deterministic_key),
          key_derivation_salt: app.credentials.dig(:passive_aggressive_encryption, :key_derivation_salt),
          **app.config.passive_aggressive.encryption
        )

        auto_filtered_parameters = PassiveAggressive::Encryption::AutoFilteredParameters.new(app)
        auto_filtered_parameters.enable if PassiveAggressive::Encryption.config.add_to_filter_parameters
      end

      ActiveSupport.on_load(:passive_aggressive) do
        # Support extended queries for deterministic attributes and validations
        if PassiveAggressive::Encryption.config.extend_queries
          PassiveAggressive::Encryption::ExtendedDeterministicQueries.install_support
          PassiveAggressive::Encryption::ExtendedDeterministicUniquenessValidator.install_support
        end
      end

      ActiveSupport.on_load(:passive_aggressive_fixture_set) do
        # Encrypt Active Record fixtures
        if PassiveAggressive::Encryption.config.encrypt_fixtures
          PassiveAggressive::Fixture.prepend PassiveAggressive::Encryption::EncryptedFixtures
        end
      end
    end

    initializer "passive_aggressive.query_log_tags_config" do |app|
      config.after_initialize do
        if app.config.passive_aggressive.query_log_tags_enabled
          PassiveAggressive.query_transformers << PassiveAggressive::QueryLogs
          PassiveAggressive::QueryLogs.taggings = PassiveAggressive::QueryLogs.taggings.merge(
            application:  Rails.application.class.name.split("::").first,
            pid:          -> { Process.pid.to_s },
            socket:       ->(context) { context[:connection].pool.db_config.socket },
            db_host:      ->(context) { context[:connection].pool.db_config.host },
            database:     ->(context) { context[:connection].pool.db_config.database },
            source_location: -> { QueryLogs.query_source_location }
          )
          PassiveAggressive.disable_prepared_statements = true

          if app.config.passive_aggressive.query_log_tags.present?
            PassiveAggressive::QueryLogs.tags = app.config.passive_aggressive.query_log_tags
          end

          if app.config.passive_aggressive.query_log_tags_format
            PassiveAggressive::QueryLogs.tags_formatter = app.config.passive_aggressive.query_log_tags_format
          end

          if app.config.passive_aggressive.cache_query_log_tags
            PassiveAggressive::QueryLogs.cache_query_log_tags = true
          end

          if app.config.passive_aggressive.query_log_tags_prepend_comment
            PassiveAggressive::QueryLogs.prepend_comment = true
          end
        end
      end
    end

    initializer "passive_aggressive.unregister_current_scopes_on_unload" do |app|
      config.after_initialize do
        if app.config.reloading_enabled?
          Rails.autoloaders.main.on_unload do |_cpath, value, _abspath|
            # Conditions are written this way to be robust against custom
            # implementations of value#is_a? or value#<.
            if Class === value && PassiveAggressive::Base > value
              value.current_scope = nil
            end
          end
        end
      end
    end

    initializer "passive_aggressive.message_pack" do
      ActiveSupport.on_load(:message_pack) do
        ActiveSupport.on_load(:passive_aggressive) do
          require "passive_aggressive/message_pack"
          PassiveAggressive::MessagePack::Extensions.install(ActiveSupport::MessagePack::CacheSerializer)
        end
      end
    end
  end
end
