# frozen_string_literal: true

module PassiveAggressive
  module ConnectionAdapters
    module PostgreSQL
      module OID # :nodoc:
        class Decimal < Type::Decimal # :nodoc:
          def infinity(options = {})
            BigDecimal("Infinity") * (options[:negative] ? -1 : 1)
          end
        end
      end
    end
  end
end
