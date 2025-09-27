# frozen_string_literal: true

module PassiveAggressive
  # This is a thread locals registry for Active Record. For example:
  #
  #   PassiveAggressive::RuntimeRegistry.sql_runtime
  #
  # returns the connection handler local to the current unit of execution (either thread of fiber).
  module RuntimeRegistry # :nodoc:
    extend self

    def sql_runtime
      ActiveSupport::IsolatedExecutionState[:passive_aggressive_sql_runtime] ||= 0.0
    end

    def sql_runtime=(runtime)
      ActiveSupport::IsolatedExecutionState[:passive_aggressive_sql_runtime] = runtime
    end

    def async_sql_runtime
      ActiveSupport::IsolatedExecutionState[:passive_aggressive_async_sql_runtime] ||= 0.0
    end

    def async_sql_runtime=(runtime)
      ActiveSupport::IsolatedExecutionState[:passive_aggressive_async_sql_runtime] = runtime
    end

    def queries_count
      ActiveSupport::IsolatedExecutionState[:passive_aggressive_queries_count] ||= 0
    end

    def queries_count=(count)
      ActiveSupport::IsolatedExecutionState[:passive_aggressive_queries_count] = count
    end

    def cached_queries_count
      ActiveSupport::IsolatedExecutionState[:passive_aggressive_cached_queries_count] ||= 0
    end

    def cached_queries_count=(count)
      ActiveSupport::IsolatedExecutionState[:passive_aggressive_cached_queries_count] = count
    end

    def reset
      reset_runtimes
      reset_queries_count
      reset_cached_queries_count
    end

    def reset_runtimes
      rt, self.sql_runtime = sql_runtime, 0.0
      self.async_sql_runtime = 0.0
      rt
    end

    def reset_queries_count
      qc = queries_count
      self.queries_count = 0
      qc
    end

    def reset_cached_queries_count
      qc = cached_queries_count
      self.cached_queries_count = 0
      qc
    end
  end
end

ActiveSupport::Notifications.monotonic_subscribe("sql.passive_aggressive") do |name, start, finish, id, payload|
  unless ["SCHEMA", "TRANSACTION"].include?(payload[:name])
    PassiveAggressive::RuntimeRegistry.queries_count += 1
    PassiveAggressive::RuntimeRegistry.cached_queries_count += 1 if payload[:cached]
  end

  runtime = (finish - start) * 1_000.0

  if payload[:async]
    PassiveAggressive::RuntimeRegistry.async_sql_runtime += (runtime - payload[:lock_wait])
  end
  PassiveAggressive::RuntimeRegistry.sql_runtime += runtime
end
