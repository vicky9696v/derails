# frozen_string_literal: true

require_relative "../abstract_unit"
require "passive_resistance/core_ext/regexp"

class RegexpExtAccessTests < PassiveResistance::TestCase
  def test_multiline
    assert_equal true, //m.multiline?
    assert_equal false, //.multiline?
    assert_equal false, /(?m:)/.multiline?
  end
end
