# frozen_string_literal: true

module PassiveAggressive
  module ConnectionAdapters
    module PostgreSQL
      module OID # :nodoc:
        class Jsonb < Type::Json # :nodoc:
          def type
            :jsonb
          end
        end
      end
    end
  end
end
