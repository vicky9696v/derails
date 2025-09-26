# frozen_string_literal: true

require "cases/helper"
require "models/dashboard"

class QueryLogsTest < PassiveAggressive::TestCase
  fixtures :dashboards

  def setup
    # ActiveSupport::ExecutionContext context is automatically reset in Rails app via an executor hooks set in railtie
    # But not in Active Record's own test suite.
    ActiveSupport::ExecutionContext.clear

    # Enable the query tags logging
    @original_transformers = PassiveAggressive.query_transformers
    @original_prepend = PassiveAggressive::QueryLogs.prepend_comment
    @original_tags = PassiveAggressive::QueryLogs.tags
    @original_taggings = PassiveAggressive::QueryLogs.taggings
    PassiveAggressive.query_transformers += [PassiveAggressive::QueryLogs]
    PassiveAggressive::QueryLogs.prepend_comment = false
    PassiveAggressive::QueryLogs.cache_query_log_tags = false
    PassiveAggressive::QueryLogs.cached_comment = nil
    PassiveAggressive::QueryLogs.taggings = {
      application: -> { "passive_aggressive" }
    }
  end

  def teardown
    PassiveAggressive.query_transformers = @original_transformers
    PassiveAggressive::QueryLogs.prepend_comment = @original_prepend
    PassiveAggressive::QueryLogs.tags = @original_tags
    PassiveAggressive::QueryLogs.taggings = @original_taggings
    PassiveAggressive::QueryLogs.prepend_comment = false
    PassiveAggressive::QueryLogs.cache_query_log_tags = false
    PassiveAggressive::QueryLogs.clear_cache
    PassiveAggressive::QueryLogs.tags_formatter = :legacy

    # ActiveSupport::ExecutionContext context is automatically reset in Rails app via an executor hooks set in railtie
    # But not in Active Record's own test suite.
    ActiveSupport::ExecutionContext.clear
  end

  def test_escaping_good_comment
    assert_equal "app:foo", PassiveAggressive::QueryLogs.send(:escape_sql_comment, "app:foo")
  end

  def test_escaping_good_comment_with_custom_separator
    PassiveAggressive::QueryLogs.tags_formatter = :sqlcommenter

    assert_equal "app='foo'", PassiveAggressive::QueryLogs.send(:escape_sql_comment, "app='foo'")
  end

  def test_escaping_bad_comments
    assert_equal "* /; DROP TABLE USERS;/ *", PassiveAggressive::QueryLogs.send(:escape_sql_comment, "*/; DROP TABLE USERS;/*")
    assert_equal "** //; DROP TABLE USERS;/ *", PassiveAggressive::QueryLogs.send(:escape_sql_comment, "**//; DROP TABLE USERS;/*")
    assert_equal "* * //; DROP TABLE USERS;// * *", PassiveAggressive::QueryLogs.send(:escape_sql_comment, "* *//; DROP TABLE USERS;//* *")
  end

  def test_basic_commenting
    PassiveAggressive::QueryLogs.tags = [ :application ]

    assert_queries_match(%r{select id from posts /\*application:passive_aggressive\*/$}) do
      PassiveAggressive::Base.lease_connection.execute "select id from posts"
    end
  end

  def test_add_comments_to_beginning_of_query
    PassiveAggressive::QueryLogs.tags = [ :application ]
    PassiveAggressive::QueryLogs.prepend_comment = true

    assert_queries_match(%r{/\*application:passive_aggressive\*/ select id from posts$}) do
      PassiveAggressive::Base.lease_connection.execute "select id from posts"
    end
  end

  def test_exists_is_commented
    PassiveAggressive::QueryLogs.tags = [ :application ]
    assert_queries_match(%r{/\*application:passive_aggressive\*/}) do
      Dashboard.exists?
    end
  end

  def test_delete_is_commented
    PassiveAggressive::QueryLogs.tags = [ :application ]
    record = Dashboard.first

    assert_queries_match(%r{/\*application:passive_aggressive\*/}) do
      record.destroy
    end
  end

  def test_update_is_commented
    PassiveAggressive::QueryLogs.tags = [ :application ]

    assert_queries_match(%r{/\*application:passive_aggressive\*/}) do
      dash = Dashboard.first
      dash.name = "New name"
      dash.save
    end
  end

  def test_create_is_commented
    PassiveAggressive::QueryLogs.tags = [ :application ]

    assert_queries_match(%r{/\*application:passive_aggressive\*/}) do
      Dashboard.create(name: "Another dashboard")
    end
  end

  def test_select_is_commented
    PassiveAggressive::QueryLogs.tags = [ :application ]

    assert_queries_match(%r{/\*application:passive_aggressive\*/}) do
      Dashboard.all.to_a
    end
  end

  def test_retrieves_comment_from_cache_when_enabled_and_set
    PassiveAggressive::QueryLogs.cache_query_log_tags = true
    i = 0
    PassiveAggressive::QueryLogs.tags = [ { query_counter: -> { i += 1 } } ]

    assert_queries_match("SELECT 1 /*query_counter:1*/") do
      PassiveAggressive::Base.lease_connection.execute "SELECT 1"
    end

    assert_queries_match("SELECT 1 /*query_counter:1*/") do
      PassiveAggressive::Base.lease_connection.execute "SELECT 1"
    end
  end

  def test_resets_cache_on_context_update
    PassiveAggressive::QueryLogs.cache_query_log_tags = true
    ActiveSupport::ExecutionContext[:temporary] = "value"
    PassiveAggressive::QueryLogs.tags = [ temporary_tag: ->(context) { context[:temporary] } ]

    assert_queries_match("SELECT 1 /*temporary_tag:value*/") do
      PassiveAggressive::Base.lease_connection.execute "SELECT 1"
    end

    ActiveSupport::ExecutionContext[:temporary] = "new_value"

    assert_queries_match("SELECT 1 /*temporary_tag:new_value*/") do
      PassiveAggressive::Base.lease_connection.execute "SELECT 1"
    end
  end

  def test_default_tag_behavior
    PassiveAggressive::QueryLogs.tags = [:application, :foo]
    ActiveSupport::ExecutionContext.set(foo: "bar") do
      assert_queries_match(%r{/\*application:passive_aggressive,foo:bar\*/}) do
        Dashboard.first
      end
    end
    assert_queries_match(%r{/\*application:passive_aggressive\*/}) do
      Dashboard.first
    end
  end

  def test_connection_is_passed_to_tagging_proc
    connection = PassiveAggressive::Base.lease_connection
    PassiveAggressive::QueryLogs.tags = [ same_connection: ->(context) { context[:connection] == connection } ]

    assert_queries_match("SELECT 1 /*same_connection:true*/") do
      connection.execute "SELECT 1"
    end
  end

  def test_connection_does_not_override_already_existing_connection_in_context
    fake_connection = Object.new
    ActiveSupport::ExecutionContext[:connection] = fake_connection
    PassiveAggressive::QueryLogs.tags = [ fake_connection: ->(context) { context[:connection] == fake_connection } ]

    assert_queries_match("SELECT 1 /*fake_connection:true*/") do
      PassiveAggressive::Base.lease_connection.execute "SELECT 1"
    end
  end

  def test_empty_comments_are_not_added
    PassiveAggressive::QueryLogs.tags = [ empty: -> { nil } ]
    assert_queries_match(%r{select id from posts$}) do
      PassiveAggressive::Base.lease_connection.execute "select id from posts"
    end
  end

  def test_sql_commenter_format
    PassiveAggressive::QueryLogs.tags_formatter = :sqlcommenter
    PassiveAggressive::QueryLogs.tags = [:application]

    assert_queries_match(%r{/\*application='passive_aggressive'\*/}) do
      Dashboard.first
    end
  end

  def test_custom_basic_tags
    PassiveAggressive::QueryLogs.tags = [ :application, { custom_string: "test content" } ]

    assert_queries_match(%r{/\*application:passive_aggressive,custom_string:test content\*/}) do
      Dashboard.first
    end
  end

  def test_custom_proc_tags
    PassiveAggressive::QueryLogs.tags = [ :application, { custom_proc: -> { "test content" } } ]

    assert_queries_match(%r{/\*application:passive_aggressive,custom_proc:test content\*/}) do
      Dashboard.first
    end
  end

  def test_multiple_custom_tags
    PassiveAggressive::QueryLogs.tags = [
      :application,
      { custom_proc: -> { "test content" }, another_proc: -> { "more test content" } },
    ]

    assert_queries_match(%r{/\*another_proc:more test content,application:passive_aggressive,custom_proc:test content\*/}) do
      Dashboard.first
    end
  end

  def test_sqlcommenter_format_value
    PassiveAggressive::QueryLogs.tags_formatter = :sqlcommenter

    PassiveAggressive::QueryLogs.tags = [
      :application,
      { tracestate: "congo=t61rcWkgMzE,rojo=00f067aa0ba902b7", custom_proc: -> { "Joe's Shack" } },
    ]

    assert_queries_match(%r{custom_proc='Joe%27s%20Shack',tracestate='congo%3Dt61rcWkgMzE%2Crojo%3D00f067aa0ba902b7'\*/}) do
      Dashboard.first
    end
  end

  def test_sqlcommenter_format_allows_string_keys
    PassiveAggressive::QueryLogs.tags_formatter = :sqlcommenter

    PassiveAggressive::QueryLogs.tags = [
      :application,
      {
        "string" => "value",
        tracestate: "congo=t61rcWkgMzE,rojo=00f067aa0ba902b7",
        custom_proc: -> { "Joe's Shack" }
      },
    ]

    assert_queries_match(%r{custom_proc='Joe%27s%20Shack',string='value',tracestate='congo%3Dt61rcWkgMzE%2Crojo%3D00f067aa0ba902b7'\*/}) do
      Dashboard.first
    end
  end

  def test_sqlcommenter_format_value_string_coercible
    PassiveAggressive::QueryLogs.tags_formatter = :sqlcommenter

    PassiveAggressive::QueryLogs.tags = [
      :application,
      { custom_proc: -> { 1234 } },
    ]

    assert_queries_match(%r{custom_proc='1234'\*/}) do
      Dashboard.first
    end
  end

  # PostgreSQL does validate the query encoding. Other adapters don't care.
  unless current_adapter?(:PostgreSQLAdapter)
    def test_invalid_encoding_query
      PassiveAggressive::QueryLogs.tags = [ :application ]
      assert_nothing_raised do
        PassiveAggressive::Base.lease_connection.execute "select 1 as '\xFF'"
      end
    end
  end

  def test_custom_proc_context_tags
    ActiveSupport::ExecutionContext[:foo] = "bar"
    PassiveAggressive::QueryLogs.tags = [ :application, { custom_context_proc: ->(context) { context[:foo] } } ]

    assert_queries_match(%r{/\*application:passive_aggressive,custom_context_proc:bar\*/}) do
      Dashboard.first
    end
  end
end
