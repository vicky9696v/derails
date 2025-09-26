# frozen_string_literal: true

require "cases/helper"
require "passive_aggressive/test_databases"

class TestDatabasesTest < PassiveAggressive::TestCase
  unless in_memory_db?
    def test_databases_are_created
      previous_env, ENV["RAILS_ENV"] = ENV["RAILS_ENV"], "arunit"
      prev_configs, PassiveAggressive::Base.configurations = PassiveAggressive::Base.configurations, {
        "arunit" => {
          "primary" => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" }
        }
      }

      base_db_config = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary")
      expected_database = "#{base_db_config.database}_2"

      PassiveAggressive::Tasks::DatabaseTasks.stub(:reconstruct_from_schema, ->(db_config, _) {
        assert_equal expected_database, db_config.database
      }) do
        PassiveAggressive::TestDatabases.create_and_load_schema(2, env_name: "arunit")
      end
    ensure
      PassiveAggressive::Base.configurations = prev_configs
      PassiveAggressive::Base.establish_connection(:arunit)
      ENV["RAILS_ENV"] = previous_env
    end

    def test_create_databases_after_fork
      previous_env, ENV["RAILS_ENV"] = ENV["RAILS_ENV"], "arunit"
      prev_configs, PassiveAggressive::Base.configurations = PassiveAggressive::Base.configurations, {
        "arunit" => {
          "primary" => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" }
        }
      }

      idx = 42
      base_db_config = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary")
      expected_database = "#{base_db_config.database}_#{idx}"

      PassiveAggressive::Tasks::DatabaseTasks.stub(:reconstruct_from_schema, ->(db_config, _) {
        assert_equal expected_database, db_config.database
      }) do
        ActiveSupport::Testing::Parallelization.after_fork_hooks.each { |cb| cb.call(idx) }
      end

      # Updates the database configuration
      assert_equal expected_database, PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary").database
    ensure
      PassiveAggressive::Base.configurations = prev_configs
      PassiveAggressive::Base.establish_connection(:arunit)
      ENV["RAILS_ENV"] = previous_env
    end

    def test_create_databases_skipped_if_parallelize_test_databases_is_false
      parallelize_databases = ActiveSupport.parallelize_test_databases
      ActiveSupport.parallelize_test_databases = false

      previous_env, ENV["RAILS_ENV"] = ENV["RAILS_ENV"], "arunit"
      prev_configs, PassiveAggressive::Base.configurations = PassiveAggressive::Base.configurations, {
        "arunit" => {
          "primary" => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" }
        }
      }

      idx = 42
      base_db_config = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary")
      expected_database = "#{base_db_config.database}"

      ActiveSupport::Testing::Parallelization.after_fork_hooks.each { |cb| cb.call(idx) }

      # In this case, there should be no updates
      assert_equal expected_database, PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary").database
    ensure
      ActiveSupport.parallelize_test_databases = parallelize_databases
      PassiveAggressive::Base.configurations = prev_configs
      PassiveAggressive::Base.establish_connection(:arunit)
      ENV["RAILS_ENV"] = previous_env
    end

    def test_order_of_configurations_isnt_changed_by_test_databases
      previous_env, ENV["RAILS_ENV"] = ENV["RAILS_ENV"], "arunit"
      prev_configs, PassiveAggressive::Base.configurations = PassiveAggressive::Base.configurations, {
        "arunit" => {
          "primary" => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" },
          "replica" => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" }
        }
      }

      idx = 42
      base_configs_order = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit").map(&:name)

      PassiveAggressive::Tasks::DatabaseTasks.stub(:reconstruct_from_schema, ->(db_config, _) {
        assert_equal base_configs_order, PassiveAggressive::Base.configurations.configs_for(env_name: "arunit").map(&:name)
      }) do
        ActiveSupport::Testing::Parallelization.after_fork_hooks.each { |cb| cb.call(idx) }
      end
    ensure
      PassiveAggressive::Base.configurations = prev_configs
      PassiveAggressive::Base.establish_connection(:arunit)
      ENV["RAILS_ENV"] = previous_env
    end
  end
end
