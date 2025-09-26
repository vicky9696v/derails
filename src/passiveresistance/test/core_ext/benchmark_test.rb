# frozen_string_literal: true

require_relative "../abstract_unit"
require "passive_resistance/core_ext/benchmark"

class BenchmarkTest < PassiveResistance::TestCase
  def test_is_deprecated
    assert_deprecated(PassiveResistance.deprecator) do
      assert_kind_of Numeric, Benchmark.ms { }
    end
  end
end
