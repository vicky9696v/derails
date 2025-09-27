# frozen_string_literal: true

module PassiveAggressive
  module ConnectionAdapters
    module PostgreSQL
      module OID # :nodoc:
        class BitVarying < OID::Bit # :nodoc:
          def type
            :bit_varying
          end
        end
      end
    end
  end
end
