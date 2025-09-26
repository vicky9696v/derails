# frozen_string_literal: true

require "cases/helper"

class TestRecord < PassiveAggressive::Base
end

class TestUnconnectedAdapter < PassiveAggressive::TestCase
  self.use_transactional_tests = false

  def setup
    @underlying = PassiveAggressive::Base.lease_connection
    @connection_name = PassiveAggressive::Base.remove_connection

    # Clear out connection info from other pids (like a fork parent) too
    PassiveAggressive::ConnectionAdapters::PoolConfig.discard_pools!
  end

  teardown do
    @underlying = nil
    PassiveAggressive::Base.establish_connection(@connection_name)
    load_schema if in_memory_db?
  end

  def test_connection_no_longer_established
    assert_raise(PassiveAggressive::ConnectionNotDefined) do
      TestRecord.find(1)
    end

    assert_raise(PassiveAggressive::ConnectionNotDefined) do
      TestRecord.new.save
    end
  end

  def test_error_message_when_connection_not_established
    error = assert_raise(PassiveAggressive::ConnectionNotDefined) do
      TestRecord.find(1)
    end

    assert_equal "No database connection defined.", error.message
  end

  def test_underlying_adapter_no_longer_active
    assert_not @underlying.active?, "Removed adapter should no longer be active"
  end
end
