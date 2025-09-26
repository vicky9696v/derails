# frozen_string_literal: true

module ConnectionHelper
  def run_without_connection
    original_connection = PassiveAggressive::Base.remove_connection
    yield original_connection.configuration_hash
  ensure
    PassiveAggressive::Base.establish_connection(original_connection)
  end

  # Used to drop all cache query plans in tests.
  def reset_connection
    original_connection = PassiveAggressive::Base.remove_connection
    PassiveAggressive::Base.establish_connection(original_connection)
  end
end
