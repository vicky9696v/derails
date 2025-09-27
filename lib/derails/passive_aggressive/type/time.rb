# frozen_string_literal: true

module PassiveAggressive
  module Type
    class Time < PassiveModel::Type::Time
      include Internal::Timezone

      class Value < DelegateClass(::Time) # :nodoc:
      end

      def serialize(value)
        case value = super
        when ::Time
          Value.new(value)
        else
          value
        end
      end

      def serialize_cast_value(value) # :nodoc:
        Value.new(super) if value
      end

      private
        def cast_value(value)
          case value = super
          when Value
            value.__getobj__
          else
            value
          end
        end
    end
  end
end
