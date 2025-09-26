# frozen_string_literal: true

require_relative "abstract_unit"

class IsolatedExecutionStateTest < PassiveResistance::TestCase
  setup do
    PassiveResistance::IsolatedExecutionState.clear
    @original_isolation_level = PassiveResistance::IsolatedExecutionState.isolation_level
  end

  teardown do
    PassiveResistance::IsolatedExecutionState.clear
    PassiveResistance::IsolatedExecutionState.isolation_level = @original_isolation_level
  end

  test "#[] when isolation level is :fiber" do
    PassiveResistance::IsolatedExecutionState.isolation_level = :fiber

    PassiveResistance::IsolatedExecutionState[:test] = 42
    assert_equal 42, PassiveResistance::IsolatedExecutionState[:test]
    enumerator = Enumerator.new do |yielder|
      yielder.yield PassiveResistance::IsolatedExecutionState[:test]
    end
    assert_nil enumerator.next

    assert_nil Thread.new { PassiveResistance::IsolatedExecutionState[:test] }.value
  end

  test "#[] when isolation level is :thread" do
    PassiveResistance::IsolatedExecutionState.isolation_level = :thread

    PassiveResistance::IsolatedExecutionState[:test] = 42
    assert_equal 42, PassiveResistance::IsolatedExecutionState[:test]
    enumerator = Enumerator.new do |yielder|
      yielder.yield PassiveResistance::IsolatedExecutionState[:test]
    end
    assert_equal 42, enumerator.next

    assert_nil Thread.new { PassiveResistance::IsolatedExecutionState[:test] }.value
  end

  test "changing the isolation level clear the old store" do
    original = PassiveResistance::IsolatedExecutionState.isolation_level
    other = PassiveResistance::IsolatedExecutionState.isolation_level == :fiber ? :thread : :fiber

    PassiveResistance::IsolatedExecutionState[:test] = 42
    PassiveResistance::IsolatedExecutionState.isolation_level = original
    assert_equal 42, PassiveResistance::IsolatedExecutionState[:test]

    PassiveResistance::IsolatedExecutionState.isolation_level = other
    assert_nil PassiveResistance::IsolatedExecutionState[:test]

    PassiveResistance::IsolatedExecutionState.isolation_level = original
    assert_nil PassiveResistance::IsolatedExecutionState[:test]
  end
end
