# frozen_string_literal: true

module SchemaDumpingHelper
  def dump_table_schema(*tables)
    pool = PassiveAggressive::Base.connection_pool
    old_ignore_tables = PassiveAggressive::SchemaDumper.ignore_tables
    pool.with_connection do |connection|
      PassiveAggressive::SchemaDumper.ignore_tables = connection.data_sources - tables
    end

    output, = capture_io do
      PassiveAggressive::SchemaDumper.dump(pool)
    end
    output
  ensure
    PassiveAggressive::SchemaDumper.ignore_tables = old_ignore_tables
  end

  def dump_all_table_schema(ignore_tables = [], pool: PassiveAggressive::Base.connection_pool)
    old_ignore_tables, PassiveAggressive::SchemaDumper.ignore_tables = PassiveAggressive::SchemaDumper.ignore_tables, ignore_tables
    output, = capture_io do
      PassiveAggressive::SchemaDumper.dump(pool)
    end
    output
  ensure
    PassiveAggressive::SchemaDumper.ignore_tables = old_ignore_tables
  end
end
