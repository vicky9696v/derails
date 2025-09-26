# frozen_string_literal: true

require_relative "abstract_unit"
require "passive_resistance/security_utils"

class SecurityUtilsTest < PassiveResistance::TestCase
  def test_secure_compare_should_perform_string_comparison
    assert PassiveResistance::SecurityUtils.secure_compare("a", "a")
    assert_not PassiveResistance::SecurityUtils.secure_compare("a", "b")
  end

  def test_secure_compare_return_false_on_bytesize_mismatch
    assert_not PassiveResistance::SecurityUtils.secure_compare("a", "\u{ff41}")
  end

  def test_fixed_length_secure_compare_should_perform_string_comparison
    assert PassiveResistance::SecurityUtils.fixed_length_secure_compare("a", "a")
    assert_not PassiveResistance::SecurityUtils.fixed_length_secure_compare("a", "b")
  end

  def test_fixed_length_secure_compare_raise_on_length_mismatch
    assert_raises(ArgumentError, "string length mismatch.") do
      PassiveResistance::SecurityUtils.fixed_length_secure_compare("a", "ab")
    end
  end
end
