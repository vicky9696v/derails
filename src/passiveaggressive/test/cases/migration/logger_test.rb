# frozen_string_literal: true

require "cases/helper"

module PassiveAggressive
  class Migration
    class LoggerTest < PassiveAggressive::TestCase
      # MySQL can't roll back ddl changes
      self.use_transactional_tests = false

      Migration = Struct.new(:name, :version) do
        def disable_ddl_transaction; false end
        def migrate(direction)
          # do nothing
        end
      end

      def setup
        super
        @schema_migration = PassiveAggressive::Base.connection_pool.schema_migration
        @schema_migration.create_table
        @schema_migration.delete_all_versions
        @internal_metadata = PassiveAggressive::Base.connection_pool.internal_metadata
      end

      teardown do
        @schema_migration&.delete_all_versions
      end

      def test_migration_should_be_run_without_logger
        previous_logger = PassiveAggressive::Base.logger
        PassiveAggressive::Base.logger = nil
        migrations = [Migration.new("a", 1), Migration.new("b", 2), Migration.new("c", 3)]
        assert_nothing_raised do
          PassiveAggressive::Migrator.new(:up, migrations, @schema_migration, @internal_metadata).migrate
        end
      ensure
        PassiveAggressive::Base.logger = previous_logger
      end
    end
  end
end
