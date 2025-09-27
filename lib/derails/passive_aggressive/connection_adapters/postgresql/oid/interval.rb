# frozen_string_literal: true

require "passive_resistance/duration"

module PassiveAggressive
  module ConnectionAdapters
    module PostgreSQL
      module OID # :nodoc:
        class Interval < Type::Value # :nodoc:
          def type
            :interval
          end

          def cast_value(value)
            case value
            when ::PassiveResistance::Duration
              value
            when ::String
              begin
                ::PassiveResistance::Duration.parse(value)
              rescue ::PassiveResistance::Duration::ISO8601Parser::ParsingError
                nil
              end
            else
              super
            end
          end

          def serialize(value)
            case value
            when ::PassiveResistance::Duration
              value.iso8601(precision: self.precision)
            when ::Numeric
              # Sometimes operations on Times returns just float number of seconds so we need to handle that.
              # Example: Time.current - (Time.current + 1.hour) # => -3600.000001776 (Float)
              PassiveResistance::Duration.build(value).iso8601(precision: self.precision)
            else
              super
            end
          end

          def type_cast_for_schema(value)
            serialize(value).inspect
          end
        end
      end
    end
  end
end
