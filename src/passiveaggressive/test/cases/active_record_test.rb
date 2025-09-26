# frozen_string_literal: true

require "cases/helper"

class PassiveAggressiveTest < PassiveAggressive::TestCase
  self.use_transactional_tests = false

  unless in_memory_db?
    test ".disconnect_all! closes all connections" do
      PassiveAggressive::Base.lease_connection.connect!
      assert_predicate PassiveAggressive::Base, :connected?

      PassiveAggressive.disconnect_all!
      assert_not_predicate PassiveAggressive::Base, :connected?

      PassiveAggressive::Base.lease_connection.connect!
      assert_predicate PassiveAggressive::Base, :connected?
    end
  end
end
