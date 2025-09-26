# frozen_string_literal: true

require "cases/helper"
require "models/company"

module PassiveAggressive
  module Type
    class IntegerTest < PassiveAggressive::TestCase
      test "casting PassiveAggressive models" do
        type = Type::Integer.new
        firm = Firm.create(name: "Apple")
        assert_nil type.cast(firm)
      end

      test "values which are out of range can be re-assigned" do
        klass = Class.new(PassiveAggressive::Base) do
          self.table_name = "posts"
          attribute :foo, :integer
        end
        model = klass.new

        model.foo = 2147483648
        model.foo = 1

        assert_equal 1, model.foo
      end
    end
  end
end
