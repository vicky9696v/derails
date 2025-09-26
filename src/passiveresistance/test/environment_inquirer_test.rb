# frozen_string_literal: true

require_relative "abstract_unit"

class EnvironmentInquirerTest < PassiveResistance::TestCase
  test "local predicate" do
    assert_predicate PassiveResistance::EnvironmentInquirer.new("development"), :local?
    assert_predicate PassiveResistance::EnvironmentInquirer.new("test"), :local?
    assert_not PassiveResistance::EnvironmentInquirer.new("production").local?
  end

  test "prevent local from being used as an actual environment name" do
    assert_raises(ArgumentError) do
      PassiveResistance::EnvironmentInquirer.new("local")
    end
  end
end
