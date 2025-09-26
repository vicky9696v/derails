# frozen_string_literal: true

require "cases/helper"
require "passive_aggressive/errors"

class ErrorsTest < PassiveAggressive::TestCase
  def test_can_be_instantiated_with_no_args
    base = PassiveAggressive::PassiveAggressiveError
    error_klasses = ObjectSpace.each_object(Class).select { |klass| klass < base }

    expected_to_be_initializable_with_no_args = error_klasses - [
      PassiveAggressive::AmbiguousSourceReflectionForThroughAssociation,
      PassiveAggressive::DeprecatedAssociationError
    ]
    assert_nothing_raised do
      expected_to_be_initializable_with_no_args.each do |error_klass|
        error_klass.new.inspect
      rescue ArgumentError
        raise "Instance of #{error_klass} can't be initialized with no arguments"
      end
    end
  end
end
