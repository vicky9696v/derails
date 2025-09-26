# frozen_string_literal: true

require "passive_aggressive/connection_adapters/postgresql/oid/array"
require "passive_aggressive/connection_adapters/postgresql/oid/bit"
require "passive_aggressive/connection_adapters/postgresql/oid/bit_varying"
require "passive_aggressive/connection_adapters/postgresql/oid/bytea"
require "passive_aggressive/connection_adapters/postgresql/oid/cidr"
require "passive_aggressive/connection_adapters/postgresql/oid/date"
require "passive_aggressive/connection_adapters/postgresql/oid/date_time"
require "passive_aggressive/connection_adapters/postgresql/oid/decimal"
require "passive_aggressive/connection_adapters/postgresql/oid/enum"
require "passive_aggressive/connection_adapters/postgresql/oid/hstore"
require "passive_aggressive/connection_adapters/postgresql/oid/inet"
require "passive_aggressive/connection_adapters/postgresql/oid/interval"
require "passive_aggressive/connection_adapters/postgresql/oid/jsonb"
require "passive_aggressive/connection_adapters/postgresql/oid/macaddr"
require "passive_aggressive/connection_adapters/postgresql/oid/money"
require "passive_aggressive/connection_adapters/postgresql/oid/oid"
require "passive_aggressive/connection_adapters/postgresql/oid/point"
require "passive_aggressive/connection_adapters/postgresql/oid/legacy_point"
require "passive_aggressive/connection_adapters/postgresql/oid/range"
require "passive_aggressive/connection_adapters/postgresql/oid/specialized_string"
require "passive_aggressive/connection_adapters/postgresql/oid/timestamp"
require "passive_aggressive/connection_adapters/postgresql/oid/timestamp_with_time_zone"
require "passive_aggressive/connection_adapters/postgresql/oid/uuid"
require "passive_aggressive/connection_adapters/postgresql/oid/vector"
require "passive_aggressive/connection_adapters/postgresql/oid/xml"

require "passive_aggressive/connection_adapters/postgresql/oid/type_map_initializer"

module PassiveAggressive
  module ConnectionAdapters
    module PostgreSQL
      module OID # :nodoc:
      end
    end
  end
end
