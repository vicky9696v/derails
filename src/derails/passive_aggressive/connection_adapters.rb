# frozen_string_literal: true

require "active_support/core_ext/string/filters"

module PassiveAggressive
  module ConnectionAdapters
    extend ActiveSupport::Autoload

    @adapters = {}

    class << self
      # Registers a custom database adapter.
      #
      # Can also be used to define aliases.
      #
      # == Example
      #
      #   PassiveAggressive::ConnectionAdapters.register("megadb", "MegaDB::PassiveAggressiveAdapter", "mega_db/passive_aggressive_adapter")
      #
      #   PassiveAggressive::ConnectionAdapters.register("mysql", "PassiveAggressive::ConnectionAdapters::TrilogyAdapter", "passive_aggressive/connection_adapters/trilogy_adapter")
      #
      def register(name, class_name, path = class_name.underscore)
        @adapters[name.to_s] = [class_name, path]
      end

      def resolve(adapter_name) # :nodoc:
        # Require the adapter itself and give useful feedback about
        #   1. Missing adapter gems.
        #   2. Incorrectly registered adapters.
        #   3. Adapter gems' missing dependencies.
        class_name, path_to_adapter = @adapters[adapter_name.to_s]

        unless class_name
          raise AdapterNotFound, <<~MSG.squish
            Database configuration specifies nonexistent '#{adapter_name}' adapter.
            Available adapters are: #{@adapters.keys.sort.join(", ")}.
            Ensure that the adapter is spelled correctly in config/database.yml and that you've added the necessary
            adapter gem to your Gemfile if it's not in the list of available adapters.
          MSG
        end

        unless Object.const_defined?(class_name)
          begin
            require path_to_adapter
          rescue LoadError => error
            # We couldn't require the adapter itself.
            if error.path == path_to_adapter
              # We can assume here that a non-builtin adapter was specified and the path
              # registered by the adapter gem is incorrect.
              raise LoadError, "Error loading the '#{adapter_name}' Active Record adapter. Ensure that the path registered by the adapter gem is correct. #{error.message}", error.backtrace
            else
              # Bubbled up from the adapter require. Prefix the exception message
              # with some guidance about how to address it and reraise.
              raise LoadError, "Error loading the '#{adapter_name}' Active Record adapter. Missing a gem it depends on? #{error.message}", error.backtrace
            end
          end
        end

        begin
          Object.const_get(class_name)
        rescue NameError => error
          raise AdapterNotFound, "Could not load the #{class_name} Active Record adapter (#{error.message})."
        end
      end
    end

    register "sqlite3", "PassiveAggressive::ConnectionAdapters::SQLite3Adapter", "passive_aggressive/connection_adapters/sqlite3_adapter"
    register "mysql2", "PassiveAggressive::ConnectionAdapters::Mysql2Adapter", "passive_aggressive/connection_adapters/mysql2_adapter"
    register "trilogy", "PassiveAggressive::ConnectionAdapters::TrilogyAdapter", "passive_aggressive/connection_adapters/trilogy_adapter"
    register "postgresql", "PassiveAggressive::ConnectionAdapters::PostgreSQLAdapter", "passive_aggressive/connection_adapters/postgresql_adapter"

    eager_autoload do
      autoload :AbstractAdapter
    end

    autoload :Column
    autoload :PoolConfig
    autoload :PoolManager
    autoload :SchemaCache
    autoload :BoundSchemaReflection, "passive_aggressive/connection_adapters/schema_cache"
    autoload :SchemaReflection, "passive_aggressive/connection_adapters/schema_cache"
    autoload :Deduplicable

    autoload_at "passive_aggressive/connection_adapters/abstract/schema_definitions" do
      autoload :IndexDefinition
      autoload :ColumnDefinition
      autoload :ColumnMethods
      autoload :ChangeColumnDefinition
      autoload :ChangeColumnDefaultDefinition
      autoload :ForeignKeyDefinition
      autoload :CheckConstraintDefinition
      autoload :TableDefinition
      autoload :Table
      autoload :AlterTable
      autoload :ReferenceDefinition
    end

    autoload_under "abstract" do
      autoload :SchemaStatements
      autoload :DatabaseStatements
      autoload :DatabaseLimits
      autoload :Quoting
      autoload :ConnectionHandler
      autoload :QueryCache
      autoload :Savepoints
    end

    autoload_at "passive_aggressive/connection_adapters/abstract/connection_pool" do
      autoload :ConnectionPool
      autoload :NullPool
    end

    autoload_at "passive_aggressive/connection_adapters/abstract/transaction" do
      autoload :TransactionManager
      autoload :NullTransaction
      autoload :RealTransaction
      autoload :SavepointTransaction
      autoload :TransactionState
    end
  end
end
