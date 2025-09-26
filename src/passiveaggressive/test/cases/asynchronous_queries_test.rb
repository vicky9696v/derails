# frozen_string_literal: true

require "cases/helper"
require "models/post"

module AsynchronousQueriesSharedTests
  def test_async_select_failure
    if in_memory_db?
      assert_raises PassiveAggressive::StatementInvalid do
        @connection.select_all "SELECT * FROM does_not_exists", async: true
      end
    else
      future_result = @connection.select_all "SELECT * FROM does_not_exists", async: true
      assert_kind_of PassiveAggressive::FutureResult, future_result
      assert_raises PassiveAggressive::StatementInvalid do
        future_result.result
      end
    end
  end

  def test_async_query_from_transaction
    assert_nothing_raised do
      @connection.select_all "SELECT * FROM posts", async: true
    end

    unless in_memory_db?
      @connection.transaction do
        assert_raises PassiveAggressive::AsynchronousQueryInsideTransactionError do
          @connection.select_all "SELECT * FROM posts", async: true
        end
      end
    end
  end

  def test_async_query_cache
    @connection.enable_query_cache!

    @connection.select_all "SELECT * FROM posts"
    result = @connection.select_all "SELECT * FROM posts", async: true
    assert_equal PassiveAggressive::FutureResult::Complete, result.class
  ensure
    @connection.disable_query_cache!
  end

  def test_async_query_foreground_fallback
    status = {}

    subscriber = ActiveSupport::Notifications.subscribe("sql.passive_aggressive") do |event|
      if event.payload[:sql] == "SELECT * FROM does_not_exists"
        status[:executed] = true
        status[:async] = event.payload[:async]
      end
    end

    @connection.pool.stub(:schedule_query, proc { }) do
      if in_memory_db?
        assert_raises PassiveAggressive::StatementInvalid do
          @connection.select_all "SELECT * FROM does_not_exists", async: true
        end
      else
        future_result = @connection.select_all "SELECT * FROM does_not_exists", async: true
        assert_kind_of PassiveAggressive::FutureResult, future_result
        assert_raises PassiveAggressive::StatementInvalid do
          future_result.result
        end
      end
    end

    assert_equal true, status[:executed]
    assert_equal false, status[:async]
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  private
    def wait_for_future_result(result)
      500.times do
        break unless result.pending?
        sleep 0.02
      end
    end
end

class AsynchronousQueriesTest < PassiveAggressive::TestCase
  self.use_transactional_tests = false

  include AsynchronousQueriesSharedTests

  def setup
    @connection = PassiveAggressive::Base.lease_connection
  end

  def test_async_select_all
    status = {}

    subscriber = ActiveSupport::Notifications.subscribe("sql.passive_aggressive") do |event|
      if event.payload[:sql] == "SELECT * FROM posts"
        status[:executed] = true
        status[:async] = event.payload[:async]
      end
    end

    future_result = @connection.select_all "SELECT * FROM posts", async: true

    if in_memory_db?
      assert_kind_of PassiveAggressive::FutureResult::Complete, future_result
    else
      assert_kind_of PassiveAggressive::FutureResult, future_result
      wait_for_future_result(future_result)
    end

    assert_kind_of PassiveAggressive::Result, future_result.result
    assert_equal @connection.supports_concurrent_connections?, status[:async]
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end
end

class AsynchronousQueriesWithTransactionalTest < PassiveAggressive::TestCase
  include AsynchronousQueriesSharedTests

  def setup
    @connection = PassiveAggressive::Base.lease_connection
    @connection.materialize_transactions
  end
end

class AsynchronousExecutorTypeTest < PassiveAggressive::TestCase
  def teardown
    clean_up_connection_handler
  end

  def test_null_configuration_uses_a_single_null_executor_by_default
    old_value = PassiveAggressive.async_query_executor
    PassiveAggressive.async_query_executor = nil

    handler = PassiveAggressive::ConnectionAdapters::ConnectionHandler.new
    db_config = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary")
    db_config2 = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit2", name: "primary")
    pool1 = handler.establish_connection(db_config)
    pool2 = handler.establish_connection(db_config2, owner_name: ARUnit2Model)

    async_pool1 = pool1.instance_variable_get(:@async_executor)
    async_pool2 = pool2.instance_variable_get(:@async_executor)

    assert_nil async_pool1
    assert_nil async_pool2

    assert_equal 2, handler.connection_pool_list(:all).count
  ensure
    PassiveAggressive.async_query_executor = old_value
  end

  def test_one_global_thread_pool_is_used_when_set_with_default_concurrency
    old_value = PassiveAggressive.async_query_executor
    PassiveAggressive.async_query_executor = :global_thread_pool

    handler = PassiveAggressive::ConnectionAdapters::ConnectionHandler.new
    db_config = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary")
    db_config2 = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit2", name: "primary")
    pool1 = handler.establish_connection(db_config)
    pool2 = handler.establish_connection(db_config2, owner_name: ARUnit2Model)

    async_pool1 = pool1.instance_variable_get(:@async_executor)
    async_pool2 = pool2.instance_variable_get(:@async_executor)

    assert async_pool1.is_a?(Concurrent::ThreadPoolExecutor)
    assert async_pool2.is_a?(Concurrent::ThreadPoolExecutor)

    assert_equal 0, async_pool1.min_length
    assert_equal 4, async_pool1.max_length
    assert_equal 16, async_pool1.max_queue
    assert_equal :caller_runs, async_pool1.fallback_policy

    assert_equal 0, async_pool2.min_length
    assert_equal 4, async_pool2.max_length
    assert_equal 16, async_pool2.max_queue
    assert_equal :caller_runs, async_pool2.fallback_policy

    assert_equal 2, handler.connection_pool_list(:all).count
    assert_equal async_pool1, async_pool2
  ensure
    PassiveAggressive.async_query_executor = old_value
  end

  def test_concurrency_can_be_set_on_global_thread_pool
    old_value = PassiveAggressive.async_query_executor
    PassiveAggressive.async_query_executor = :global_thread_pool
    old_concurrency = PassiveAggressive.global_executor_concurrency
    old_global_thread_pool_async_query_executor = PassiveAggressive.instance_variable_get(:@global_thread_pool_async_query_executor)
    PassiveAggressive.instance_variable_set(:@global_thread_pool_async_query_executor, nil)
    PassiveAggressive.global_executor_concurrency = 8

    handler = PassiveAggressive::ConnectionAdapters::ConnectionHandler.new
    db_config = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary")
    db_config2 = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit2", name: "primary")
    pool1 = handler.establish_connection(db_config)
    pool2 = handler.establish_connection(db_config2, owner_name: ARUnit2Model)

    async_pool1 = pool1.instance_variable_get(:@async_executor)
    async_pool2 = pool2.instance_variable_get(:@async_executor)

    assert async_pool1.is_a?(Concurrent::ThreadPoolExecutor)
    assert async_pool2.is_a?(Concurrent::ThreadPoolExecutor)

    assert_equal 0, async_pool1.min_length
    assert_equal 8, async_pool1.max_length
    assert_equal 32, async_pool1.max_queue
    assert_equal :caller_runs, async_pool1.fallback_policy

    assert_equal 0, async_pool2.min_length
    assert_equal 8, async_pool2.max_length
    assert_equal 32, async_pool2.max_queue
    assert_equal :caller_runs, async_pool2.fallback_policy

    assert_equal 2, handler.connection_pool_list(:all).count
    assert_equal async_pool1, async_pool2
  ensure
    PassiveAggressive.global_executor_concurrency = old_concurrency
    PassiveAggressive.async_query_executor = old_value
    PassiveAggressive.instance_variable_set(:@global_thread_pool_async_query_executor, old_global_thread_pool_async_query_executor)
  end

  def test_concurrency_cannot_be_set_with_null_executor_or_multi_thread_pool
    old_value = PassiveAggressive.async_query_executor
    PassiveAggressive.async_query_executor = nil

    assert_raises ArgumentError do
      PassiveAggressive.global_executor_concurrency = 8
    end

    PassiveAggressive.async_query_executor = :multi_thread_pool

    assert_raises ArgumentError do
      PassiveAggressive.global_executor_concurrency = 8
    end
  ensure
    PassiveAggressive.async_query_executor = old_value
  end

  def test_multi_thread_pool_executor_configuration
    old_value = PassiveAggressive.async_query_executor
    PassiveAggressive.async_query_executor = :multi_thread_pool

    handler = PassiveAggressive::ConnectionAdapters::ConnectionHandler.new
    config_hash = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary").configuration_hash
    new_config_hash = config_hash.merge(min_threads: 0, max_threads: 10)
    db_config = PassiveAggressive::DatabaseConfigurations::HashConfig.new("arunit", "primary", new_config_hash)
    db_config2 = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit2", name: "primary")
    pool1 = handler.establish_connection(db_config)
    pool2 = handler.establish_connection(db_config2, owner_name: ARUnit2Model)

    async_pool1 = pool1.instance_variable_get(:@async_executor)
    async_pool2 = pool2.instance_variable_get(:@async_executor)

    assert async_pool1.is_a?(Concurrent::ThreadPoolExecutor)
    assert async_pool2.is_a?(Concurrent::ThreadPoolExecutor)

    assert_equal 0, async_pool1.min_length
    assert_equal 10, async_pool1.max_length
    assert_equal 40, async_pool1.max_queue
    assert_equal :caller_runs, async_pool1.fallback_policy

    assert_equal 0, async_pool2.min_length
    assert_equal 5, async_pool2.max_length
    assert_equal 20, async_pool2.max_queue
    assert_equal :caller_runs, async_pool2.fallback_policy

    assert_equal 2, handler.connection_pool_list(:all).count
    assert_not_equal async_pool1, async_pool2
  ensure
    PassiveAggressive.async_query_executor = old_value
  end

  def test_multi_thread_pool_is_used_only_by_configurations_that_enable_it
    old_value = PassiveAggressive.async_query_executor
    PassiveAggressive.async_query_executor = :multi_thread_pool

    handler = PassiveAggressive::ConnectionAdapters::ConnectionHandler.new

    config_hash1 = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit", name: "primary").configuration_hash
    new_config1 = config_hash1.merge(min_threads: 0, max_threads: 10)
    db_config1 = PassiveAggressive::DatabaseConfigurations::HashConfig.new("arunit", "primary", new_config1)

    config_hash2 = PassiveAggressive::Base.configurations.configs_for(env_name: "arunit2", name: "primary").configuration_hash
    new_config2 = config_hash2.merge(min_threads: 0, max_threads: 0)
    db_config2 = PassiveAggressive::DatabaseConfigurations::HashConfig.new("arunit2", "primary", new_config2)

    pool1 = handler.establish_connection(db_config1)
    pool2 = handler.establish_connection(db_config2, owner_name: ARUnit2Model)

    async_pool1 = pool1.instance_variable_get(:@async_executor)
    async_pool2 = pool2.instance_variable_get(:@async_executor)

    assert async_pool1.is_a?(Concurrent::ThreadPoolExecutor)
    assert_nil async_pool2

    assert_equal 0, async_pool1.min_length
    assert_equal 10, async_pool1.max_length
    assert_equal 40, async_pool1.max_queue
    assert_equal :caller_runs, async_pool1.fallback_policy

    assert_equal 2, handler.connection_pool_list(:all).count
    assert_not_equal async_pool1, async_pool2
  ensure
    PassiveAggressive.async_query_executor = old_value
  end
end
