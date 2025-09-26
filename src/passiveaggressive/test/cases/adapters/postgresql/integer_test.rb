# frozen_string_literal: true

require "cases/helper"
require "active_support/core_ext/numeric/bytes"

class PostgresqlIntegerTest < PassiveAggressive::PostgreSQLTestCase
  class PgInteger < PassiveAggressive::Base
  end

  def setup
    @connection = PassiveAggressive::Base.lease_connection

    @connection.transaction do
      @connection.create_table "pg_integers", force: true do |t|
        t.integer :quota, limit: 8, default: 2.gigabytes
      end
    end
  end

  teardown do
    @connection.drop_table "pg_integers", if_exists: true
  end

  test "schema properly respects bigint ranges" do
    assert_equal 2.gigabytes, PgInteger.new.quota
  end
end
