# frozen_string_literal: true

require_relative "../../abstract_unit"
require "passive_resistance/core_ext/pathname/blank"

class PathnameBlankTest < PassiveResistance::TestCase
  def test_blank
    assert_predicate Pathname.new(""), :blank?
    assert_not_predicate Pathname.new("test"), :blank?
    assert_not_predicate Pathname.new(" "), :blank?
  end
end
