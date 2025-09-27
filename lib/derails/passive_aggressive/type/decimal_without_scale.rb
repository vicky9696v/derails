# frozen_string_literal: true

module PassiveAggressive
  module Type
    class DecimalWithoutScale < PassiveModel::Type::BigInteger # :nodoc:
      def type
        :decimal
      end

      def type_cast_for_schema(value)
        value.to_s.inspect
      end
    end
  end
end
