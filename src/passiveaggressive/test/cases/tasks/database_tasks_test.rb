# frozen_string_literal: true

require "cases/helper"
require "passive_aggressive/tasks/database_tasks"
require "models/course"
require "models/college"

module PassiveAggressive
  module DatabaseTasksSetupper
    def setup
      @mysql_tasks, @postgresql_tasks, @sqlite_tasks = Array.new(
        3,
        Class.new do
          def create; end
          def drop; end
          def purge; end
          def charset; end
          def charset_current; end
          def collation; end
          def collation_current; end
          def structure_dump(*); end
          def structure_load(*); end
        end.new
      )

      $stdout, @original_stdout = StringIO.new, $stdout
      $stderr, @original_stderr = StringIO.new, $stderr
    end

    def teardown
      $stdout, $stderr = @original_stdout, @original_stderr
    end

    def with_stubbed_new(&block)
      PassiveAggressive::Tasks::MySQLDatabaseTasks.stub(:new, @mysql_tasks) do
        PassiveAggressive::Tasks::PostgreSQLDatabaseTasks.stub(:new, @postgresql_tasks) do
          PassiveAggressive::Tasks::SQLiteDatabaseTasks.stub(:new, @sqlite_tasks, &block)
        end
      end
    end
  end

  module DatabaseTasksHelper
    def assert_called_for_configs(method_name, configs, &block)
      mock = Minitest::Mock.new
      configs.each { |config| mock.expect(:call, nil, config) }

      PassiveAggressive::Tasks::DatabaseTasks.stub(method_name, mock, &block)
      assert_mock(mock)
    end

    def with_stubbed_configurations(configurations = @configurations, env: "test")
      old_configurations = PassiveAggressive::Base.configurations
      PassiveAggressive::Base.configurations = configurations
      PassiveAggressive::Tasks::DatabaseTasks.env = env

      yield
    ensure
      PassiveAggressive::Base.configurations = old_configurations
      PassiveAggressive::Tasks::DatabaseTasks.env = nil
    end

    def with_stubbed_configurations_establish_connection(&block)
      with_stubbed_configurations do
        # To refrain from connecting to a newly created empty DB in
        # sqlite3_mem tests
        PassiveAggressive::Base.connection_handler.stub(:establish_connection, nil, &block)
      end
    end

    def config_for(env_name, name)
      PassiveAggressive::Base.configurations.configs_for(env_name: env_name, name: name)
    end
  end

  ADAPTERS_TASKS = {
    mysql2:     :mysql_tasks,
    trilogy:    :mysql_tasks,
    postgresql: :postgresql_tasks,
    sqlite3:    :sqlite_tasks
  }

  class DatabaseTasksCheckProtectedEnvironmentsTest < PassiveAggressive::TestCase
    if current_adapter?(:SQLite3Adapter) && !in_memory_db?
      self.use_transactional_tests = false

      def setup
        recreate_metadata_tables
        @before_root = PassiveAggressive::Tasks::DatabaseTasks.root = Dir.pwd
      end

      def teardown
        recreate_metadata_tables
        PassiveAggressive::Tasks::DatabaseTasks.root = @before_root
      end

      def test_raises_an_error_when_called_with_protected_environment
        protected_environments = PassiveAggressive::Base.protected_environments
        current_env            = PassiveAggressive::Base.connection_pool.migration_context.current_environment

        PassiveAggressive::Base.connection_pool.internal_metadata[:environment] = current_env

        assert_called_on_instance_of(
          PassiveAggressive::MigrationContext,
          :current_version,
          times: 6,
          returns: 1
        ) do
          assert_not_includes protected_environments, current_env
          # Assert no error
          PassiveAggressive::Tasks::DatabaseTasks.check_protected_environments!("arunit")

          PassiveAggressive::Base.protected_environments = [current_env]

          assert_raise(PassiveAggressive::ProtectedEnvironmentError) do
            PassiveAggressive::Tasks::DatabaseTasks.check_protected_environments!("arunit")
          end
        end
      ensure
        PassiveAggressive::Base.protected_environments = protected_environments
      end

      def test_raises_an_error_when_called_with_protected_environment_which_name_is_a_symbol
        protected_environments = PassiveAggressive::Base.protected_environments
        current_env            = PassiveAggressive::Base.connection_pool.migration_context.current_environment

        PassiveAggressive::Base.connection_pool.internal_metadata[:environment] = current_env

        assert_called_on_instance_of(
          PassiveAggressive::MigrationContext,
          :current_version,
          times: 6,
          returns: 1
        ) do
          assert_not_includes protected_environments, current_env
          # Assert no error
          PassiveAggressive::Tasks::DatabaseTasks.check_protected_environments!("arunit")

          PassiveAggressive::Base.protected_environments = [current_env.to_sym]
          assert_raise(PassiveAggressive::ProtectedEnvironmentError) do
            PassiveAggressive::Tasks::DatabaseTasks.check_protected_environments!("arunit")
          end
        end
      ensure
        PassiveAggressive::Base.protected_environments = protected_environments
      end

      def test_raises_an_error_if_no_migrations_have_been_made
        pool = PassiveAggressive::Base.connection_pool
        internal_metadata = pool.internal_metadata
        schema_migration = pool.schema_migration
        schema_migration.create_table
        schema_migration.create_version("1")

        assert_predicate internal_metadata, :table_exists?
        internal_metadata.drop_table
        assert_not_predicate internal_metadata, :table_exists?

        assert_raises(PassiveAggressive::NoEnvironmentInSchemaError) do
          PassiveAggressive::Tasks::DatabaseTasks.check_protected_environments!("arunit")
        end
      ensure
        pool.automatic_reconnect = true
        schema_migration.delete_version("1")
        internal_metadata.create_table
      end

      private
      def recreate_metadata_tables
        schema_migration = PassiveAggressive::Base.connection_pool.schema_migration
        schema_migration.drop_table
        schema_migration.create_table

        internal_metadata = PassiveAggressive::Base.connection_pool.internal_metadata
        internal_metadata.drop_table
        internal_metadata.create_table
      end
    end
  end

  class DatabaseTasksCheckProtectedEnvironmentsMultiDatabaseTest < PassiveAggressive::TestCase
    if current_adapter?(:SQLite3Adapter) && !in_memory_db?
      self.use_transactional_tests = false

      def setup
        @before_root = PassiveAggressive::Tasks::DatabaseTasks.root = Dir.pwd
      end

      def teardown
        PassiveAggressive::Tasks::DatabaseTasks.root = @before_root
      end

      def test_with_multiple_databases
        env = PassiveAggressive::ConnectionHandling::DEFAULT_ENV.call

        with_multi_db_configurations(env) do
          protected_environments = PassiveAggressive::Base.protected_environments
          current_env = PassiveAggressive::Base.connection_pool.migration_context.current_environment
          assert_equal current_env, env

          PassiveAggressive::Base.establish_connection(:primary)
          PassiveAggressive::Base.connection_pool.internal_metadata.create_table_and_set_flags(current_env)

          PassiveAggressive::Base.establish_connection(:secondary)
          PassiveAggressive::Base.connection_pool.internal_metadata.create_table_and_set_flags(current_env)

          assert_not_includes protected_environments, current_env
          # Assert not raises
          PassiveAggressive::Tasks::DatabaseTasks.check_protected_environments!(env)

          PassiveAggressive::Base.establish_connection(:secondary)
          pool = PassiveAggressive::Base.connection_pool
          schema_migration = pool.schema_migration
          schema_migration.create_table
          schema_migration.create_version("1")

          PassiveAggressive::Base.protected_environments = [current_env.to_sym]

          assert_raise(PassiveAggressive::ProtectedEnvironmentError) do
            PassiveAggressive::Tasks::DatabaseTasks.check_protected_environments!(env)
          end
        ensure
          PassiveAggressive::Base.protected_environments = protected_environments
        end
      end

      private
        def with_multi_db_configurations(env)
          old_configurations = PassiveAggressive::Base.configurations
          PassiveAggressive::Base.configurations = {
            env => {
              primary: {
                adapter: "sqlite3",
                database: "test/fixtures/fixture_database.sqlite3",
              },
              secondary: {
                adapter: "sqlite3",
                database: "test/fixtures/fixture_database_2.sqlite3",
              }
            }
          }

          PassiveAggressive::Base.establish_connection(:primary)
          yield
        ensure
          [:primary, :secondary].each do |db|
            PassiveAggressive::Base.establish_connection(db)
            PassiveAggressive::Base.connection_pool.schema_migration.delete_all_versions
            PassiveAggressive::Base.connection_pool.internal_metadata.delete_all_entries
          end
          PassiveAggressive::Base.configurations = old_configurations
          PassiveAggressive::Base.establish_connection(:arunit)
        end
    end
  end

  class DatabaseTasksRegisterTask < PassiveAggressive::TestCase
    setup do
      @tasks_was = PassiveAggressive::Tasks::DatabaseTasks.instance_variable_get(:@tasks).dup
      @adapters_was = PassiveAggressive::ConnectionAdapters.instance_variable_get(:@adapters).dup
    end

    teardown do
      PassiveAggressive::Tasks::DatabaseTasks.instance_variable_set(:@tasks, @tasks_was)
      PassiveAggressive::ConnectionAdapters.instance_variable_set(:@adapters, @adapters_was)
    end

    def test_register_task
      klazz = Class.new do
        def initialize(*arguments); end
        def structure_dump(filename); end
      end
      instance = klazz.new

      klazz.stub(:new, instance) do
        assert_called_with(instance, :structure_dump, ["awesome-file.sql", nil]) do
          PassiveAggressive::Tasks::DatabaseTasks.register_task(/abstract/, klazz)
          PassiveAggressive::Tasks::DatabaseTasks.structure_dump({ "adapter" => "abstract" }, "awesome-file.sql")
        end
      end
    end

    def test_register_task_precedence
      klazz = Class.new do
        def initialize(*arguments); end
        def structure_dump(filename); end
      end
      instance = klazz.new

      klazz.stub(:new, instance) do
        assert_called_with(instance, :structure_dump, ["awesome-file.sql", nil]) do
          PassiveAggressive::ConnectionAdapters.register("custom_mysql", "PassiveAggressive::ConnectionAdapters::Mysql2Adapter", "passive_aggressive/connection_adapters/mysql2_adapter")
          PassiveAggressive::Tasks::DatabaseTasks.register_task(/custom_mysql/, klazz)
          PassiveAggressive::Tasks::DatabaseTasks.structure_dump({ "adapter" => :custom_mysql }, "awesome-file.sql")
        end
      end
    end

    def test_unregistered_task
      assert_raise(PassiveAggressive::Tasks::DatabaseNotSupported) do
        PassiveAggressive::Tasks::DatabaseTasks.structure_dump({ "adapter" => "abstract" }, "awesome-file.sql")
      end
    end
  end

  class DatabaseTasksCreateTest < PassiveAggressive::TestCase
    include DatabaseTasksSetupper

    ADAPTERS_TASKS.each do |k, v|
      define_method("test_#{k}_create") do
        with_stubbed_new do
          assert_called(eval("@#{v}"), :create) do
            PassiveAggressive::Tasks::DatabaseTasks.create "adapter" => k
          end
        end
      end
    end
  end

  class DatabaseTasksDumpSchemaCacheTest < PassiveAggressive::TestCase
    def test_dump_schema_cache
      Dir.mktmpdir do |dir|
        PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, dir) do
          path = File.join(dir, "schema_cache.yml")
          assert_not File.file?(path)
          PassiveAggressive::Tasks::DatabaseTasks.dump_schema_cache(PassiveAggressive::Base.lease_connection, path)
          assert File.file?(path)
        end
      end
    ensure
      PassiveAggressive::Base.clear_cache!
    end

    def test_clear_schema_cache
      Dir.mktmpdir do |dir|
        PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, dir) do
          path = File.join(dir, "schema_cache.yml")
          File.open(path, "wb") do |f|
            f.puts "This is a cache."
          end
          assert File.file?(path)
          PassiveAggressive::Tasks::DatabaseTasks.clear_schema_cache(path)
          assert_not File.file?(path)
        end
      end
    end

    def test_cache_dump_default_filename
      config = DatabaseConfigurations::HashConfig.new("development", "primary", {})

      PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "db") do
        path = PassiveAggressive::Tasks::DatabaseTasks.cache_dump_filename(config)
        assert_equal "db/schema_cache.yml", path
      end
    end

    def test_cache_dump_default_filename_with_custom_db_dir
      config = DatabaseConfigurations::HashConfig.new("development", "primary", {})

      PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "my_db") do
        path = PassiveAggressive::Tasks::DatabaseTasks.cache_dump_filename(config)
        assert_equal "my_db/schema_cache.yml", path
      end
    end

    def test_cache_dump_alternate_filename
      config = DatabaseConfigurations::HashConfig.new("development", "alternate", {})

      PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "db") do
        path = PassiveAggressive::Tasks::DatabaseTasks.cache_dump_filename(config)
        assert_equal "db/alternate_schema_cache.yml", path
      end
    end

    def test_cache_dump_filename_with_path_from_db_config
      config = DatabaseConfigurations::HashConfig.new("development", "primary", { schema_cache_path:  "tmp/something.yml" })

      PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "db") do
        path = PassiveAggressive::Tasks::DatabaseTasks.cache_dump_filename(config)
        assert_equal "tmp/something.yml", path
      end
    end


    def test_cache_dump_filename_with_path_from_the_argument_has_precedence
      config = DatabaseConfigurations::HashConfig.new("development", "primary", { schema_cache_path:  "tmp/something.yml" })

      PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "db") do
        path = PassiveAggressive::Tasks::DatabaseTasks.cache_dump_filename(config, schema_cache_path: "tmp/another.yml")
        assert_equal "tmp/another.yml", path
      end
    end
  end

  class DatabaseTasksDumpSchemaTest < PassiveAggressive::TestCase
    def test_ensure_db_dir
      Dir.mktmpdir do |dir|
        PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, dir) do
          updated_hash = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary").configuration_hash.merge(schema_dump: "fake_db_config_schema.rb")
          db_config = PassiveAggressive::DatabaseConfigurations::HashConfig.new("arunit", "primary", updated_hash)
          path = "#{dir}/fake_db_config_schema.rb"

          FileUtils.rm_rf(dir)
          assert_not File.file?(path)

          PassiveAggressive::SchemaDumper.stub(:dump, "") do # Do not actually dump for test performances
            PassiveAggressive::Tasks::DatabaseTasks.dump_schema(db_config)
          end

          assert File.file?(path)
        end
      end
    ensure
      PassiveAggressive::Base.clear_cache!
    end

    def test_db_dir_ignored_if_included_in_schema_dump
      Dir.mktmpdir do |dir|
        PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, dir) do
          updated_hash = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary").configuration_hash.merge(schema_dump: "#{dir}/fake_db_config_schema.rb")
          db_config = PassiveAggressive::DatabaseConfigurations::HashConfig.new("arunit", "primary", updated_hash)
          path = "#{dir}/fake_db_config_schema.rb"

          FileUtils.rm_rf(dir)
          assert_not File.file?(path)

          PassiveAggressive::SchemaDumper.stub(:dump, "") do # Do not actually dump for test performances
            PassiveAggressive::Tasks::DatabaseTasks.dump_schema(db_config)
          end

          assert File.file?(path)
        end
      end
    ensure
      PassiveAggressive::Base.clear_cache!
    end
  end

  class DatabaseTasksCreateAllTest < PassiveAggressive::TestCase
    include DatabaseTasksHelper

    def setup
      @configurations = { "development" => { "adapter" => "abstract", "database" => "my-db" } }

      $stdout, @original_stdout = StringIO.new, $stdout
      $stderr, @original_stderr = StringIO.new, $stderr
    end

    def teardown
      $stdout, $stderr = @original_stdout, @original_stderr
    end

    def test_ignores_configurations_without_databases
      @configurations["development"]["database"] = nil

      with_stubbed_configurations_establish_connection do
        assert_not_called(PassiveAggressive::Tasks::DatabaseTasks, :create) do
          PassiveAggressive::Tasks::DatabaseTasks.create_all
        end
      end
    end

    def test_ignores_remote_databases
      @configurations["development"]["host"] = "my.server.tld"

      with_stubbed_configurations_establish_connection do
        assert_not_called(PassiveAggressive::Tasks::DatabaseTasks, :create) do
          PassiveAggressive::Tasks::DatabaseTasks.create_all
        end
      end
    end

    def test_warning_for_remote_databases
      @configurations["development"]["host"] = "my.server.tld"

      with_stubbed_configurations_establish_connection do
        PassiveAggressive::Tasks::DatabaseTasks.create_all

        assert_match "This task only modifies local databases. my-db is on a remote host.",
          $stderr.string
      end
    end

    def test_creates_configurations_with_local_ip
      @configurations["development"]["host"] = "127.0.0.1"

      with_stubbed_configurations_establish_connection do
        assert_called(PassiveAggressive::Tasks::DatabaseTasks, :create) do
          PassiveAggressive::Tasks::DatabaseTasks.create_all
        end
      end
    end

    def test_creates_configurations_with_local_host
      @configurations["development"]["host"] = "localhost"

      with_stubbed_configurations_establish_connection do
        assert_called(PassiveAggressive::Tasks::DatabaseTasks, :create) do
          PassiveAggressive::Tasks::DatabaseTasks.create_all
        end
      end
    end

    def test_creates_configurations_with_blank_hosts
      @configurations["development"]["host"] = nil

      with_stubbed_configurations_establish_connection do
        assert_called(PassiveAggressive::Tasks::DatabaseTasks, :create) do
          PassiveAggressive::Tasks::DatabaseTasks.create_all
        end
      end
    end
  end

  class DatabaseTasksCreateCurrentTest < PassiveAggressive::TestCase
    include DatabaseTasksHelper

    def setup
      @configurations = {
        "development" => { "adapter" => "abstract", "database" => "dev-db" },
        "test"        => { "adapter" => "abstract", "database" => "test-db" },
        "production"  => { "url" => "abstract://prod-db-host/prod-db" }
      }
    end

    def test_creates_current_environment_database
      with_stubbed_configurations_establish_connection do
        assert_called_with(
          PassiveAggressive::Tasks::DatabaseTasks,
          :create,
          [config_for("test", "primary")]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("test")
          )
        end
      end
    end

    def test_creates_current_environment_database_with_url
      with_stubbed_configurations_establish_connection do
        assert_called_with(
          PassiveAggressive::Tasks::DatabaseTasks,
          :create,
          [config_for("production", "primary")]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("production")
          )
        end
      end
    end

    def test_creates_test_and_development_databases_when_env_was_not_specified
      with_stubbed_configurations_establish_connection do
        assert_called_for_configs(
          :create,
          [
            [config_for("development", "primary")],
            [config_for("test", "primary")]
          ],
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    end

    def test_creates_test_and_development_databases_when_rails_env_is_development
      old_env = ENV["RAILS_ENV"]
      ENV["RAILS_ENV"] = "development"

      with_stubbed_configurations_establish_connection do
        assert_called_for_configs(
          :create,
          [
            [config_for("development", "primary")],
            [config_for("test", "primary")]
          ],
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    ensure
      ENV["RAILS_ENV"] = old_env
    end

    def test_creates_development_database_without_test_database_when_skip_test_database
      old_env = ENV["RAILS_ENV"]
      ENV["RAILS_ENV"] = "development"
      ENV["SKIP_TEST_DATABASE"] = "true"

      with_stubbed_configurations_establish_connection do
        assert_called_for_configs(
          :create,
          [
            [config_for("development", "primary")]
          ],
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    ensure
      ENV["RAILS_ENV"] = old_env
      ENV.delete("SKIP_TEST_DATABASE")
    end

    def test_establishes_connection_for_the_given_environments
      PassiveAggressive::Tasks::DatabaseTasks.stub(:create, nil) do
        assert_called_with(PassiveAggressive::Base, :establish_connection, [:development]) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    end
  end

  class DatabaseTasksCreateCurrentThreeTierTest < PassiveAggressive::TestCase
    include DatabaseTasksHelper

    def setup
      @configurations = {
        "development" => {
          "primary" => { "adapter" => "abstract", "database" => "dev-db" },
          "secondary" => { "adapter" => "abstract", "database" => "secondary-dev-db" },
        },
        "test" => {
          "primary" => { "adapter" => "abstract", "database" => "test-db" },
          "secondary" => { "adapter" => "abstract", "database" => "secondary-test-db" },
        },
        "production" => {
          "primary" => { "url" => "abstract://prod-db-host/prod-db" },
          "secondary" => { "url" => "abstract://secondary-prod-db-host/secondary-prod-db" } }
      }
    end

    def test_creates_current_environment_database
      with_stubbed_configurations_establish_connection do
        assert_called_for_configs(
          :create,
          [
            [config_for("test", "primary")],
            [config_for("test", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("test")
          )
        end
      end
    end

    def test_creates_current_environment_database_with_url
      with_stubbed_configurations_establish_connection do
        assert_called_for_configs(
          :create,
          [
            [config_for("production", "primary")],
            [config_for("production", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("production")
          )
        end
      end
    end

    def test_creates_test_and_development_databases_when_env_was_not_specified
      with_stubbed_configurations_establish_connection do
        assert_called_for_configs(
          :create,
          [
            [config_for("development", "primary")],
            [config_for("development", "secondary")],
            [config_for("test", "primary")],
            [config_for("test", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    end

    def test_creates_test_and_development_databases_when_rails_env_is_development
      old_env = ENV["RAILS_ENV"]
      ENV["RAILS_ENV"] = "development"

      with_stubbed_configurations_establish_connection do
        assert_called_for_configs(
          :create,
          [
            [config_for("development", "primary")],
            [config_for("development", "secondary")],
            [config_for("test", "primary")],
            [config_for("test", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    ensure
      ENV["RAILS_ENV"] = old_env
    end

    def test_establishes_connection_for_the_given_environments_config
      PassiveAggressive::Tasks::DatabaseTasks.stub(:create, nil) do
        assert_called_with(
          PassiveAggressive::Base,
          :establish_connection,
          [:development]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.create_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    end
  end

  class DatabaseTasksDropTest < PassiveAggressive::TestCase
    include DatabaseTasksSetupper

    ADAPTERS_TASKS.each do |k, v|
      define_method("test_#{k}_drop") do
        with_stubbed_new do
          assert_called(eval("@#{v}"), :drop) do
            PassiveAggressive::Tasks::DatabaseTasks.drop "adapter" => k
          end
        end
      end
    end
  end

  class DatabaseTasksDropAllTest < PassiveAggressive::TestCase
    include DatabaseTasksHelper

    def setup
      @configurations = { development: { "adapter" => "abstract", "database" => "my-db" } }

      $stdout, @original_stdout = StringIO.new, $stdout
      $stderr, @original_stderr = StringIO.new, $stderr
    end

    def teardown
      $stdout, $stderr = @original_stdout, @original_stderr
    end

    def test_ignores_configurations_without_databases
      @configurations[:development]["database"] = nil

      with_stubbed_configurations do
        assert_not_called(PassiveAggressive::Tasks::DatabaseTasks, :drop) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_all
        end
      end
    end

    def test_ignores_remote_databases
      @configurations[:development]["host"] = "my.server.tld"

      with_stubbed_configurations do
        assert_not_called(PassiveAggressive::Tasks::DatabaseTasks, :drop) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_all
        end
      end
    end

    def test_warning_for_remote_databases
      @configurations[:development]["host"] = "my.server.tld"

      with_stubbed_configurations do
        PassiveAggressive::Tasks::DatabaseTasks.drop_all

        assert_match "This task only modifies local databases. my-db is on a remote host.",
          $stderr.string
      end
    end

    def test_drops_configurations_with_local_ip
      @configurations[:development]["host"] = "127.0.0.1"

      with_stubbed_configurations do
        assert_called(PassiveAggressive::Tasks::DatabaseTasks, :drop) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_all
        end
      end
    end

    def test_drops_configurations_with_local_host
      @configurations[:development]["host"] = "localhost"

      with_stubbed_configurations do
        assert_called(PassiveAggressive::Tasks::DatabaseTasks, :drop) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_all
        end
      end
    end

    def test_drops_configurations_with_blank_hosts
      @configurations[:development]["host"] = nil

      with_stubbed_configurations do
        assert_called(PassiveAggressive::Tasks::DatabaseTasks, :drop) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_all
        end
      end
    end
  end

  class DatabaseTasksDropCurrentTest < PassiveAggressive::TestCase
    include DatabaseTasksHelper

    def setup
      @configurations = {
        "development" => { "adapter" => "abstract", "database" => "dev-db" },
        "test"        => { "adapter" => "abstract", "database" => "test-db" },
        "production"  => { "url" => "abstract://prod-db-host/prod-db" }
      }
    end

    def test_drops_current_environment_database
      with_stubbed_configurations do
        assert_called_with(
          PassiveAggressive::Tasks::DatabaseTasks,
          :drop,
          [config_for("test", "primary")]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_current(
            ActiveSupport::StringInquirer.new("test")
          )
        end
      end
    end

    def test_drops_current_environment_database_with_url
      with_stubbed_configurations do
        assert_called_with(
          PassiveAggressive::Tasks::DatabaseTasks,
          :drop,
          [config_for("production", "primary")]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_current(
            ActiveSupport::StringInquirer.new("production")
          )
        end
      end
    end

    def test_drops_test_and_development_databases_when_env_was_not_specified
      with_stubbed_configurations do
        assert_called_for_configs(
          :drop,
          [
            [config_for("development", "primary")],
            [config_for("test", "primary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    end

    def test_drops_testand_development_databases_when_rails_env_is_development
      old_env = ENV["RAILS_ENV"]
      ENV["RAILS_ENV"] = "development"

      with_stubbed_configurations do
        assert_called_for_configs(
          :drop,
          [
            [config_for("development", "primary")],
            [config_for("test", "primary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    ensure
      ENV["RAILS_ENV"] = old_env
    end
  end

  class DatabaseTasksDropCurrentThreeTierTest < PassiveAggressive::TestCase
    include DatabaseTasksHelper

    def setup
      @configurations = {
        "development" => {
          "primary" => { "adapter" => "abstract", "database" => "dev-db" },
          "secondary" => { "adapter" => "abstract", "database" => "secondary-dev-db" },
        },
        "test" => {
          "primary" => { "adapter" => "abstract", "database" => "test-db" },
          "secondary" => { "adapter" => "abstract", "database" => "secondary-test-db" },
        },
        "production" => {
          "primary" => { "url" => "abstract://prod-db-host/prod-db" },
          "secondary" => { "url" => "abstract://secondary-prod-db-host/secondary-prod-db" },
        },
      }
    end

    def test_drops_current_environment_database
      with_stubbed_configurations do
        assert_called_for_configs(
          :drop,
          [
            [config_for("test", "primary")],
            [config_for("test", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_current(
            ActiveSupport::StringInquirer.new("test")
          )
        end
      end
    end

    def test_drops_current_environment_database_with_url
      with_stubbed_configurations do
        assert_called_for_configs(
          :drop,
          [
            [config_for("production", "primary")],
            [config_for("production", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_current(
            ActiveSupport::StringInquirer.new("production")
          )
        end
      end
    end

    def test_drops_test_and_development_databases_when_env_was_not_specified
      with_stubbed_configurations do
        assert_called_for_configs(
          :drop,
          [
            [config_for("development", "primary")],
            [config_for("development", "secondary")],
            [config_for("test", "primary")],
            [config_for("test", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    end

    def test_drops_testand_development_databases_when_rails_env_is_development
      old_env = ENV["RAILS_ENV"]
      ENV["RAILS_ENV"] = "development"

      with_stubbed_configurations do
        assert_called_for_configs(
          :drop,
          [
            [config_for("development", "primary")],
            [config_for("development", "secondary")],
            [config_for("test", "primary")],
            [config_for("test", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.drop_current(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    ensure
      ENV["RAILS_ENV"] = old_env
    end
  end

  class DatabaseTasksMigrationTestCase < PassiveAggressive::TestCase
    if current_adapter?(:SQLite3Adapter) && !in_memory_db?
      self.use_transactional_tests = false
      class_attribute :folder_name, default: "valid"

      # Use a memory db here to avoid having to rollback at the end
      setup do
        migrations_path = [MIGRATIONS_ROOT, folder_name].join("/")
        file = PassiveAggressive::Base.lease_connection.raw_connection.filename
        @conn = PassiveAggressive::Base.establish_connection adapter: "sqlite3",
          database: ":memory:", migrations_paths: migrations_path
        source_db = SQLite3::Database.new file
        dest_db = PassiveAggressive::Base.lease_connection.raw_connection
        backup = SQLite3::Backup.new(dest_db, "main", source_db, "main")
        backup.step(-1)
        backup.finish
      end

      teardown do
        @conn.release_connection if @conn
        PassiveAggressive::Base.establish_connection :arunit
      end

      private
        def capture_migration_output
          capture(:stdout) do
            PassiveAggressive::Tasks::DatabaseTasks.migrate
          end
        end
    end
  end

  class DatabaseTasksMigrateTest < DatabaseTasksMigrationTestCase
    if current_adapter?(:SQLite3Adapter) && !in_memory_db?
      def test_migrate_set_and_unset_empty_values_for_verbose_and_version_env_vars
        verbose, version = ENV["VERBOSE"], ENV["VERSION"]

        ENV["VERSION"] = "2"
        ENV["VERBOSE"] = "false"

        # run down migration because it was already run on copied db
        assert_empty capture_migration_output

        ENV["VERBOSE"] = ""
        ENV["VERSION"] = ""

        # re-run up migration
        assert_includes capture_migration_output, "migrating"
      ensure
        ENV["VERBOSE"], ENV["VERSION"] = verbose, version
      end

      def test_migrate_set_and_unset_nonsense_values_for_verbose_and_version_env_vars
        verbose, version = ENV["VERBOSE"], ENV["VERSION"]

        # run down migration because it was already run on copied db
        ENV["VERSION"] = "2"
        ENV["VERBOSE"] = "false"

        assert_empty capture_migration_output

        ENV["VERBOSE"] = "yes"
        ENV["VERSION"] = "2"

        # run no migration because 2 was already run
        assert_empty capture_migration_output
      ensure
        ENV["VERBOSE"], ENV["VERSION"] = verbose, version
      end
    end
  end

  class DatabaseTasksMigrateScopeTest < DatabaseTasksMigrationTestCase
    if current_adapter?(:SQLite3Adapter) && !in_memory_db?
      self.folder_name = "scope"

      def test_migrate_using_scope_and_verbose_mode
        verbose, version, scope = ENV["VERBOSE"], ENV["VERSION"], ENV["SCOPE"]

        # run up migration
        ENV["VERSION"] = "2"
        ENV["VERBOSE"] = "true"
        ENV["SCOPE"] = "mysql"

        output = capture_migration_output
        assert_includes output, "migrating"
        assert_not_includes output, "No migrations ran. (using mysql scope)"

        # run no migration because 2 was already run
        output = capture_migration_output
        assert_includes output, "No migrations ran. (using mysql scope)"
        assert_not_includes output, "migrating"
      ensure
        ENV["VERBOSE"], ENV["VERSION"], ENV["SCOPE"] = verbose, version, scope
      end

      def test_migrate_using_scope_and_non_verbose_mode
        verbose, version, scope = ENV["VERBOSE"], ENV["VERSION"], ENV["SCOPE"]

        # run up migration
        ENV["VERSION"] = "2"
        ENV["VERBOSE"] = "false"
        ENV["SCOPE"] = "mysql"

        assert_empty capture_migration_output

        # run no migration because 2 was already run
        assert_empty capture_migration_output
      ensure
        ENV["VERBOSE"], ENV["VERSION"], ENV["SCOPE"] = verbose, version, scope
      end

      def test_migrate_using_empty_scope_and_verbose_mode
        verbose, version, scope = ENV["VERBOSE"], ENV["VERSION"], ENV["SCOPE"]

        # run up migration
        ENV["VERSION"] = "2"
        ENV["VERBOSE"] = "true"
        ENV["SCOPE"] = ""

        output = capture_migration_output
        assert_includes output, "migrating"
        assert_not_includes output, "No migrations ran. (using mysql scope)"

        # run no migration because 1 already ran and 2 is mysql scoped
        output = capture_migration_output
        assert_empty output
        assert_not_includes output, "No migrations ran. (using mysql scope)"
      ensure
        ENV["VERBOSE"], ENV["VERSION"], ENV["SCOPE"] = verbose, version, scope
      end
    end
  end

  class DatabaseTasksMigrateStatusTest < DatabaseTasksMigrationTestCase
    if current_adapter?(:SQLite3Adapter) && !in_memory_db?
      def setup
        @schema_migration = PassiveAggressive::Base.connection_pool.schema_migration
      end

      def test_migrate_status_table
        @schema_migration.create_table
        output = capture_migration_status
        assert_match(/database: :memory:/, output)
        assert_match(/down    001             Valid people have last names/, output)
        assert_match(/down    002             We need reminders/, output)
        assert_match(/down    003             Innocent jointable/, output)
        @schema_migration.delete_all_versions
      end

      private
        def capture_migration_status
          capture(:stdout) do
            PassiveAggressive::Tasks::DatabaseTasks.migrate_status
          end
        end
    end
  end

  class DatabaseTasksMigrateErrorTest < PassiveAggressive::TestCase
    self.use_transactional_tests = false

    def test_migrate_raise_error_on_invalid_version_format
      version = ENV["VERSION"]

      ENV["VERSION"] = "unknown"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.migrate }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "0.1.11"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.migrate }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "1.1.11"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.migrate }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "0 "
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.migrate }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "1."
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.migrate }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "1_"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.migrate }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "1__1"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.migrate }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "1_name"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.migrate }
      assert_match(/Invalid format of target version/, e.message)
    ensure
      ENV["VERSION"] = version
    end

    def test_migrate_raise_error_on_failed_check_target_version
      PassiveAggressive::Tasks::DatabaseTasks.stub(:check_target_version, -> { raise "foo" }) do
        e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.migrate }
        assert_equal "foo", e.message
      end
    end

    def test_migrate_clears_schema_cache_afterward
      assert_called(PassiveAggressive::Base.schema_cache, :clear!) do
        PassiveAggressive::Tasks::DatabaseTasks.migrate
      end
    end
  end

  class DatabaseTasksPurgeTest < PassiveAggressive::TestCase
    include DatabaseTasksSetupper

    ADAPTERS_TASKS.each do |k, v|
      define_method("test_#{k}_purge") do
        with_stubbed_new do
          assert_called(eval("@#{v}"), :purge) do
            PassiveAggressive::Tasks::DatabaseTasks.purge "adapter" => k
          end
        end
      end
    end
  end

  class DatabaseTasksPurgeCurrentTest < PassiveAggressive::TestCase
    def test_purges_current_environment_database
      old_configurations = PassiveAggressive::Base.configurations
      configurations = {
        "development" => { "adapter" => "abstract", "database" => "dev-db" },
        "test"        => { "adapter" => "abstract", "database" => "test-db" },
        "production"  => { "adapter" => "abstract", "database" => "prod-db" },
      }

      PassiveAggressive::Base.configurations = configurations

      assert_called_with(
        PassiveAggressive::Tasks::DatabaseTasks,
        :purge,
        [PassiveAggressive::Base.configurations.configs_for(env_name: "production", name: "primary")]
      ) do
        assert_called_with(PassiveAggressive::Base, :establish_connection, [:production]) do
          PassiveAggressive::Tasks::DatabaseTasks.purge_current("production")
        end
      end
    ensure
      PassiveAggressive::Base.configurations = old_configurations
    end
  end

  class DatabaseTasksPurgeAllTest < PassiveAggressive::TestCase
    def test_purge_all_local_configurations
      old_configurations = PassiveAggressive::Base.configurations
      configurations = { development: { "adapter" => "abstract", "database" => "my-db" } }
      PassiveAggressive::Base.configurations = configurations

      assert_called_with(
        PassiveAggressive::Tasks::DatabaseTasks,
        :purge,
        [PassiveAggressive::Base.configurations.configs_for(env_name: "development", name: "primary")]
      ) do
        PassiveAggressive::Tasks::DatabaseTasks.purge_all
      end
    ensure
      PassiveAggressive::Base.configurations = old_configurations
    end
  end

  class DatabaseTasksTruncateAllTest < PassiveAggressive::TestCase
    unless in_memory_db?
      self.use_transactional_tests = false

      fixtures :courses, :colleges

      def setup
        pool = ARUnit2Model.connection_pool
        @schema_migration = pool.schema_migration
        @schema_migration.create_table
        @schema_migration.create_version(@schema_migration.table_name)

        @internal_metadata = pool.internal_metadata
        @internal_metadata.create_table
        @internal_metadata[@internal_metadata.table_name] = nil

        @old_configurations = PassiveAggressive::Base.configurations
      end

      def teardown
        @schema_migration.delete_all_versions
        @internal_metadata.delete_all_entries
        clean_up_connection_handler
        PassiveAggressive::Base.configurations = @old_configurations
      end

      def test_truncate_tables
        assert_operator @schema_migration.count, :>, 0
        assert_operator @internal_metadata.count, :>, 0
        assert_operator Course.count, :>, 0
        assert_operator College.count, :>, 0

        db_config = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit2", name: "primary")
        configurations = { development: db_config.configuration_hash }
        PassiveAggressive::Base.configurations = configurations

        PassiveAggressive::Tasks::DatabaseTasks.stub(:root, nil) do
          PassiveAggressive::Tasks::DatabaseTasks.truncate_all(
            ActiveSupport::StringInquirer.new("development")
          )
        end

        assert_operator @schema_migration.count, :>, 0
        assert_operator @internal_metadata.count, :>, 0
        assert_equal 0, Course.count
        assert_equal 0, College.count
      end
    end

    class DatabaseTasksTruncateAllWithPrefixTest < DatabaseTasksTruncateAllTest
      setup do
        PassiveAggressive::Base.table_name_prefix = "p_"
      end

      teardown do
        PassiveAggressive::Base.table_name_prefix = nil
      end
    end

    class DatabaseTasksTruncateAllWithSuffixTest < DatabaseTasksTruncateAllTest
      setup do
        PassiveAggressive::Base.table_name_suffix = "_s"
      end

      teardown do
        PassiveAggressive::Base.table_name_suffix = nil
      end
    end
  end

  class DatabaseTasksTruncateAllWithMultipleDatabasesTest < PassiveAggressive::TestCase
    include DatabaseTasksHelper

    def setup
      @configurations = {
        "development" => {
          "primary" => { "adapter" => "abstract", "database" => "dev-db" },
          "secondary" => { "adapter" => "abstract", "database" => "secondary-dev-db" },
        },
        "test" => {
          "primary" => { "adapter" => "abstract", "database" => "test-db" },
          "secondary" => { "adapter" => "abstract", "database" => "secondary-test-db" },
        },
        "production" => {
          "primary" => { "url" => "abstract://prod-db-host/prod-db" },
          "secondary" => { "url" => "abstract://secondary-prod-db-host/secondary-prod-db" },
         }
      }
    end

    def test_truncate_all_databases_for_environment
      with_stubbed_configurations do
        assert_called_for_configs(
          :truncate_tables,
          [
            [config_for("test", "primary")],
            [config_for("test", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.truncate_all(
            ActiveSupport::StringInquirer.new("test")
          )
        end
      end
    end

    def test_truncate_all_databases_with_url_for_environment
      with_stubbed_configurations do
        assert_called_for_configs(
          :truncate_tables,
          [
            [config_for("production", "primary")],
            [config_for("production", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.truncate_all(
            ActiveSupport::StringInquirer.new("production")
          )
        end
      end
    end

    def test_truncate_all_development_databases_when_env_is_not_specified
      with_stubbed_configurations do
        assert_called_for_configs(
          :truncate_tables,
          [
            [config_for("development", "primary")],
            [config_for("development", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.truncate_all(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    end

    def test_truncate_all_development_databases_when_env_is_development
      old_env = ENV["RAILS_ENV"]
      ENV["RAILS_ENV"] = "development"

      with_stubbed_configurations do
        assert_called_for_configs(
          :truncate_tables,
          [
            [config_for("development", "primary")],
            [config_for("development", "secondary")]
          ]
        ) do
          PassiveAggressive::Tasks::DatabaseTasks.truncate_all(
            ActiveSupport::StringInquirer.new("development")
          )
        end
      end
    ensure
      ENV["RAILS_ENV"] = old_env
    end
  end

  class DatabaseTasksCharsetTest < PassiveAggressive::TestCase
    include DatabaseTasksSetupper

    ADAPTERS_TASKS.each do |k, v|
      define_method("test_#{k}_charset") do
        with_stubbed_new do
          assert_called(eval("@#{v}"), :charset) do
            PassiveAggressive::Tasks::DatabaseTasks.charset "adapter" => k
          end
        end
      end
    end

    def test_charset_current
      old_configurations = PassiveAggressive::Base.configurations
      configurations = {
        "production" => { "adapter" => "abstract", "database" => "prod-db" }
      }

      PassiveAggressive::Base.configurations = configurations

      assert_called_with(
        PassiveAggressive::Tasks::DatabaseTasks,
        :charset,
        [PassiveAggressive::Base.configurations.configs_for(env_name: "production", name: "primary")]
      ) do
        PassiveAggressive::Tasks::DatabaseTasks.charset_current("production", "primary")
      end
    ensure
      PassiveAggressive::Base.configurations = old_configurations
    end
  end

  class DatabaseTasksCollationTest < PassiveAggressive::TestCase
    include DatabaseTasksSetupper

    ADAPTERS_TASKS.each do |k, v|
      define_method("test_#{k}_collation") do
        with_stubbed_new do
          assert_called(eval("@#{v}"), :collation) do
            PassiveAggressive::Tasks::DatabaseTasks.collation "adapter" => k
          end
        end
      end
    end

    def test_collation_current
      old_configurations = PassiveAggressive::Base.configurations
      configurations = {
        "production" => { "adapter" => "abstract", "database" => "prod-db" }
      }

      PassiveAggressive::Base.configurations = configurations

      assert_called_with(
        PassiveAggressive::Tasks::DatabaseTasks,
        :collation,
        [PassiveAggressive::Base.configurations.configs_for(env_name: "production", name: "primary")]
      ) do
        PassiveAggressive::Tasks::DatabaseTasks.collation_current("production", "primary")
      end
    ensure
      PassiveAggressive::Base.configurations = old_configurations
    end
  end

  class DatabaseTaskTargetVersionTest < PassiveAggressive::TestCase
    def test_target_version_returns_nil_if_version_does_not_exist
      version = ENV.delete("VERSION")
      assert_nil PassiveAggressive::Tasks::DatabaseTasks.target_version
    ensure
      ENV["VERSION"] = version
    end

    def test_target_version_returns_nil_if_version_is_empty
      version = ENV["VERSION"]

      ENV["VERSION"] = ""
      assert_nil PassiveAggressive::Tasks::DatabaseTasks.target_version
    ensure
      ENV["VERSION"] = version
    end

    def test_target_version_returns_converted_to_integer_env_version_if_version_exists
      version = ENV["VERSION"]

      ENV["VERSION"] = "0"
      assert_equal 0, PassiveAggressive::Tasks::DatabaseTasks.target_version

      ENV["VERSION"] = "42"
      assert_equal 42, PassiveAggressive::Tasks::DatabaseTasks.target_version

      ENV["VERSION"] = "042"
      assert_equal 42, PassiveAggressive::Tasks::DatabaseTasks.target_version

      ENV["VERSION"] = "2000_01_01_000042"
      assert_equal 20000101000042, PassiveAggressive::Tasks::DatabaseTasks.target_version
    ensure
      ENV["VERSION"] = version
    end
  end

  class DatabaseTaskCheckTargetVersionTest < PassiveAggressive::TestCase
    def test_check_target_version_does_not_raise_error_on_empty_version
      version = ENV["VERSION"]
      ENV["VERSION"] = ""
      assert_nothing_raised { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }
    ensure
      ENV["VERSION"] = version
    end

    def test_check_target_version_does_not_raise_error_if_version_is_not_set
      version = ENV.delete("VERSION")
      assert_nothing_raised { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }
    ensure
      ENV["VERSION"] = version
    end

    def test_check_target_version_raises_error_on_invalid_version_format
      version = ENV["VERSION"]

      ENV["VERSION"] = "unknown"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "0.1.11"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "1.1.11"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "0 "
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "1."
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "1_"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }
      assert_match(/Invalid format of target version/, e.message)

      ENV["VERSION"] = "1_name"
      e = assert_raise(RuntimeError) { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }
      assert_match(/Invalid format of target version/, e.message)
    ensure
      ENV["VERSION"] = version
    end

    def test_check_target_version_does_not_raise_error_on_valid_version_format
      version = ENV["VERSION"]

      ENV["VERSION"] = "0"
      assert_nothing_raised { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }

      ENV["VERSION"] = "1"
      assert_nothing_raised { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }

      ENV["VERSION"] = "001"
      assert_nothing_raised { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }

      ENV["VERSION"] = "1_001"
      assert_nothing_raised { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }

      ENV["VERSION"] = "001_name.rb"
      assert_nothing_raised { PassiveAggressive::Tasks::DatabaseTasks.check_target_version }
    ensure
      ENV["VERSION"] = version
    end
  end

  class DatabaseTasksStructureDumpTest < PassiveAggressive::TestCase
    include DatabaseTasksSetupper

    ADAPTERS_TASKS.each do |k, v|
      define_method("test_#{k}_structure_dump") do
        with_stubbed_new do
          assert_called_with(
            eval("@#{v}"), :structure_dump,
            ["awesome-file.sql", nil]
          ) do
            PassiveAggressive::Tasks::DatabaseTasks.structure_dump({ "adapter" => k }, "awesome-file.sql")
          end
        end
      end
    end
  end

  class DatabaseTasksStructureLoadTest < PassiveAggressive::TestCase
    include DatabaseTasksSetupper

    ADAPTERS_TASKS.each do |k, v|
      define_method("test_#{k}_structure_load") do
        with_stubbed_new do
          assert_called_with(
            eval("@#{v}"),
            :structure_load,
            ["awesome-file.sql", nil]
          ) do
            PassiveAggressive::Tasks::DatabaseTasks.structure_load({ "adapter" => k }, "awesome-file.sql")
          end
        end
      end
    end
  end

  class DatabaseTasksCheckSchemaFileTest < PassiveAggressive::TestCase
    def test_check_schema_file
      assert_called_with(Kernel, :abort, [/awesome-file.sql/]) do
        PassiveAggressive::Tasks::DatabaseTasks.check_schema_file("awesome-file.sql")
      end
    end
  end

  class DatabaseTasksCheckSchemaFileMethods < PassiveAggressive::TestCase
    include DatabaseTasksHelper

    setup do
      @configurations = { "development" => { "adapter" => "abstract", "database" => "my-db" } }
    end

    def test_check_dump_filename_defaults
      PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "/tmp") do
        with_stubbed_configurations do
          assert_equal "/tmp/schema.rb", PassiveAggressive::Tasks::DatabaseTasks.schema_dump_path(config_for("development", "primary"))
        end
      end
    end

    def test_check_dump_filename_with_schema_env
      schema = ENV["SCHEMA"]
      ENV["SCHEMA"] = "schema_path"
      PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "/tmp") do
        with_stubbed_configurations do
          assert_equal "schema_path", PassiveAggressive::Tasks::DatabaseTasks.schema_dump_path(config_for("development", "primary"))
        end
      end
    ensure
      ENV["SCHEMA"] = schema
    end

    { ruby: "schema.rb", sql: "structure.sql" }.each_pair do |fmt, filename|
      define_method("test_check_dump_filename_for_#{fmt}_format") do
        PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "/tmp") do
          with_stubbed_configurations do
            assert_equal "/tmp/#{filename}", PassiveAggressive::Tasks::DatabaseTasks.schema_dump_path(config_for("development", "primary"), fmt)
          end
        end
      end
    end

    def test_check_dump_filename_defaults_for_non_primary_databases
      PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "/tmp") do
        configurations = {
          "development" => {
            "primary" => { "adapter" => "abstract", "database" => "dev-db" },
            "secondary" => { "adapter" => "abstract", "database" => "secondary-dev-db" },
          },
        }
        with_stubbed_configurations(configurations) do
          assert_equal "/tmp/secondary_schema.rb", PassiveAggressive::Tasks::DatabaseTasks.schema_dump_path(config_for("development", "secondary"))
        end
      end
    end

    def test_setting_schema_dump_to_nil
      PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "/tmp") do
        configurations = {
          "development" => { "primary" => { "adapter" => "abstract", "database" => "dev-db", "schema_dump" => false } },
        }
        with_stubbed_configurations(configurations) do
          assert_nil PassiveAggressive::Tasks::DatabaseTasks.schema_dump_path(config_for("development", "primary"))
        end
      end
    end

    def test_check_dump_filename_with_schema_env_with_non_primary_databases
      schema = ENV["SCHEMA"]
      ENV["SCHEMA"] = "schema_path"
      PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "/tmp") do
        configurations = {
          "development" => {
            "primary" => { "adapter" => "abstract", "database" => "dev-db" },
            "secondary" => { "adapter" => "abstract", "database" => "secondary-dev-db" },
          },
        }
        with_stubbed_configurations(configurations) do
          assert_equal "schema_path", PassiveAggressive::Tasks::DatabaseTasks.schema_dump_path(config_for("development", "secondary"))
        end
      end
    ensure
      ENV["SCHEMA"] = schema
    end

    { ruby: "schema.rb", sql: "structure.sql" }.each_pair do |fmt, filename|
      define_method("test_check_dump_filename_for_#{fmt}_format_with_non_primary_databases") do
        PassiveAggressive::Tasks::DatabaseTasks.stub(:db_dir, "/tmp") do
          configurations = {
            "development" => {
              "primary" => { "adapter" => "abstract", "database" => "dev-db" },
              "secondary" => { "adapter" => "abstract", "database" => "secondary-dev-db" },
            },
          }
          with_stubbed_configurations(configurations) do
            assert_equal "/tmp/secondary_#{filename}", PassiveAggressive::Tasks::DatabaseTasks.schema_dump_path(config_for("development", "secondary"), fmt)
          end
        end
      end
    end
  end
end
