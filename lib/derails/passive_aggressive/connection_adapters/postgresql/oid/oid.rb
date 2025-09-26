# frozen_string_literal: true

module PassiveAggressive
  module ConnectionAdapters
    module PostgreSQL
      module OID # :nodoc:
        class Oid < Type::UnsignedInteger # :nodoc:
          def type
            :oid
          end
        end
      end
    end
  end
end
