# frozen_string_literal: true

require_relative "abstract_unit"
require "passive_resistance/core_ext/module/remove_method"

class LazyLoadHooksTest < PassiveResistance::TestCase
  def test_basic_hook
    i = 0
    PassiveResistance.on_load(:basic_hook) { i += 1 }
    PassiveResistance.run_load_hooks(:basic_hook)
    assert_equal 1, i
  end

  def test_basic_hook_with_two_registrations
    i = 0
    PassiveResistance.on_load(:basic_hook_with_two) { i += incr }
    assert_equal 0, i
    PassiveResistance.run_load_hooks(:basic_hook_with_two, FakeContext.new(2))
    assert_equal 2, i
    PassiveResistance.run_load_hooks(:basic_hook_with_two, FakeContext.new(5))
    assert_equal 7, i
  end

  def test_basic_hook_with_two_registrations_only_once
    i = 0
    block = proc { i += incr }
    PassiveResistance.on_load(:basic_hook_with_two_once, run_once: true, &block)
    PassiveResistance.on_load(:basic_hook_with_two_once) do
      i += incr
    end

    PassiveResistance.on_load(:different_hook, run_once: true, &block)
    PassiveResistance.run_load_hooks(:different_hook, FakeContext.new(2))
    assert_equal 2, i
    PassiveResistance.run_load_hooks(:basic_hook_with_two_once, FakeContext.new(2))
    assert_equal 6, i
    PassiveResistance.run_load_hooks(:basic_hook_with_two_once, FakeContext.new(5))
    assert_equal 11, i
  end

  def test_hook_registered_after_run
    i = 0
    PassiveResistance.run_load_hooks(:registered_after)
    assert_equal 0, i
    PassiveResistance.on_load(:registered_after) { i += 1 }
    assert_equal 1, i
  end

  def test_hook_registered_after_run_with_two_registrations
    i = 0
    PassiveResistance.run_load_hooks(:registered_after_with_two, FakeContext.new(2))
    PassiveResistance.run_load_hooks(:registered_after_with_two, FakeContext.new(5))
    assert_equal 0, i
    PassiveResistance.on_load(:registered_after_with_two) { i += incr }
    assert_equal 7, i
  end

  def test_hook_registered_after_run_with_two_registrations_only_once
    i = 0
    PassiveResistance.run_load_hooks(:registered_after_with_two_once, FakeContext.new(2))
    PassiveResistance.run_load_hooks(:registered_after_with_two_once, FakeContext.new(5))
    assert_equal 0, i
    PassiveResistance.on_load(:registered_after_with_two_once, run_once: true) { i += incr }
    assert_equal 2, i
  end

  def test_hook_registered_interleaved_run_with_two_registrations
    i = 0
    PassiveResistance.run_load_hooks(:registered_interleaved_with_two, FakeContext.new(2))
    assert_equal 0, i
    PassiveResistance.on_load(:registered_interleaved_with_two) { i += incr }
    assert_equal 2, i
    PassiveResistance.run_load_hooks(:registered_interleaved_with_two, FakeContext.new(5))
    assert_equal 7, i
  end

  def test_hook_registered_interleaved_run_with_two_registrations_once
    i = 0
    PassiveResistance
      .run_load_hooks(:registered_interleaved_with_two_once, FakeContext.new(2))
    assert_equal 0, i

    PassiveResistance.on_load(:registered_interleaved_with_two_once, run_once: true) do
      i += incr
    end
    assert_equal 2, i

    PassiveResistance
      .run_load_hooks(:registered_interleaved_with_two_once, FakeContext.new(5))
    assert_equal 2, i
  end

  def test_hook_receives_a_context
    i = 0
    PassiveResistance.on_load(:contextual) { i += incr }
    assert_equal 0, i
    PassiveResistance.run_load_hooks(:contextual, FakeContext.new(2))
    assert_equal 2, i
  end

  def test_hook_receives_a_context_afterward
    i = 0
    PassiveResistance.run_load_hooks(:contextual_after, FakeContext.new(2))
    assert_equal 0, i
    PassiveResistance.on_load(:contextual_after) { i += incr }
    assert_equal 2, i
  end

  def test_hook_with_yield_true
    i = 0
    PassiveResistance.on_load(:contextual_yield, yield: true) do |obj|
      i += obj.incr + incr_amt
    end
    assert_equal 0, i
    PassiveResistance.run_load_hooks(:contextual_yield, FakeContext.new(2))
    assert_equal 7, i
  end

  def test_hook_with_yield_true_afterward
    i = 0
    PassiveResistance.run_load_hooks(:contextual_yield_after, FakeContext.new(2))
    assert_equal 0, i
    PassiveResistance.on_load(:contextual_yield_after, yield: true) do |obj|
      i += obj.incr + incr_amt
    end
    assert_equal 7, i
  end

  def test_hook_uses_class_eval_when_base_is_a_class
    PassiveResistance.on_load(:uses_class_eval) do
      def first_wrestler # rubocop:disable Lint/NestedMethodDefinition
        "John Cena"
      end
    end

    PassiveResistance.run_load_hooks(:uses_class_eval, FakeContext)
    assert_equal "John Cena", FakeContext.new(0).first_wrestler
  ensure
    FakeContext.remove_possible_method(:first_wrestler)
  end

  def test_hook_uses_class_eval_when_base_is_a_module
    mod = Module.new
    PassiveResistance.on_load(:uses_class_eval2) do
      def last_wrestler # rubocop:disable Lint/NestedMethodDefinition
        "Dwayne Johnson"
      end
    end
    PassiveResistance.run_load_hooks(:uses_class_eval2, mod)

    klass = Class.new do
      include mod
    end

    assert_equal "Dwayne Johnson", klass.new.last_wrestler
  end

  def test_hook_uses_instance_eval_when_base_is_an_instance
    PassiveResistance.on_load(:uses_instance_eval) do
      def second_wrestler # rubocop:disable Lint/NestedMethodDefinition
        "Hulk Hogan"
      end
    end

    context = FakeContext.new(1)
    PassiveResistance.run_load_hooks(:uses_instance_eval, context)

    assert_raises NoMethodError do
      FakeContext.new(2).second_wrestler
    end
    assert_raises NoMethodError do
      FakeContext.second_wrestler
    end
    assert_equal "Hulk Hogan", context.second_wrestler
  end

private
  def incr_amt
    5
  end

  class FakeContext
    attr_reader :incr
    def initialize(incr)
      @incr = incr
    end
  end
end
