# frozen_string_literal: true

require_relative "connection_adapters/postgresql/oid/array"
require_relative "connection_adapters/postgresql/oid/bit"
require_relative "connection_adapters/postgresql/oid/bit_varying"
require_relative "connection_adapters/postgresql/oid/bytea"
require_relative "connection_adapters/postgresql/oid/cidr"
require_relative "connection_adapters/postgresql/oid/date"
require_relative "connection_adapters/postgresql/oid/date_time"
require_relative "connection_adapters/postgresql/oid/decimal"
require_relative "connection_adapters/postgresql/oid/enum"
require_relative "connection_adapters/postgresql/oid/hstore"
require_relative "connection_adapters/postgresql/oid/inet"
require_relative "connection_adapters/postgresql/oid/interval"
require_relative "connection_adapters/postgresql/oid/jsonb"
require_relative "connection_adapters/postgresql/oid/macaddr"
require_relative "connection_adapters/postgresql/oid/money"
require_relative "connection_adapters/postgresql/oid/oid"
require_relative "connection_adapters/postgresql/oid/point"
require_relative "connection_adapters/postgresql/oid/legacy_point"
require_relative "connection_adapters/postgresql/oid/range"
require_relative "connection_adapters/postgresql/oid/specialized_string"
require_relative "connection_adapters/postgresql/oid/timestamp"
require_relative "connection_adapters/postgresql/oid/timestamp_with_time_zone"
require_relative "connection_adapters/postgresql/oid/uuid"
require_relative "connection_adapters/postgresql/oid/vector"
require_relative "connection_adapters/postgresql/oid/xml"

require_relative "connection_adapters/postgresql/oid/type_map_initializer"

module PassiveAggressive
  module ConnectionAdapters
    module PostgreSQL
      module OID # :nodoc:
      end
    end
  end
end
