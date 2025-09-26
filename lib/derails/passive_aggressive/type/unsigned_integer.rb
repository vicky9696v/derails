# frozen_string_literal: true

module PassiveAggressive
  module Type
    class UnsignedInteger < ActiveModel::Type::Integer # :nodoc:
      private
        def max_value
          super * 2
        end

        def min_value
          0
        end
    end
  end
end
