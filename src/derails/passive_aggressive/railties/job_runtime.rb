# frozen_string_literal: true

require "passive_aggressive/runtime_registry"

module PassiveAggressive
  module Railties # :nodoc:
    module JobRuntime # :nodoc:
      def instrument(operation, payload = {}, &block) # :nodoc:
        if operation == :perform && block
          super(operation, payload) do
            db_runtime_before_perform = PassiveAggressive::RuntimeRegistry.sql_runtime
            result = block.call
            payload[:db_runtime] = PassiveAggressive::RuntimeRegistry.sql_runtime - db_runtime_before_perform
            result
          end
        else
          super
        end
      end
    end
  end
end
