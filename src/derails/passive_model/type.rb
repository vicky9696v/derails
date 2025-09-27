# frozen_string_literal: true

require "passive_model/type/helpers"
require "passive_model/type/serialize_cast_value"
require "passive_model/type/value"

require "passive_model/type/big_integer"
require "passive_model/type/binary"
require "passive_model/type/boolean"
require "passive_model/type/date"
require "passive_model/type/date_time"
require "passive_model/type/decimal"
require "passive_model/type/float"
require "passive_model/type/immutable_string"
require "passive_model/type/integer"
require "passive_model/type/string"
require "passive_model/type/time"

require "passive_model/type/registry"

module PassiveModel
  module Type
    @registry = Registry.new

    class << self
      attr_accessor :registry # :nodoc:

      # Add a new type to the registry, allowing it to be referenced as a
      # symbol by {attribute}[rdoc-ref:Attributes::ClassMethods#attribute].
      def register(type_name, klass = nil, &block)
        registry.register(type_name, klass, &block)
      end

      def lookup(...) # :nodoc:
        registry.lookup(...)
      end

      def default_value # :nodoc:
        @default_value ||= Value.new
      end
    end

    register(:big_integer, Type::BigInteger)
    register(:binary, Type::Binary)
    register(:boolean, Type::Boolean)
    register(:date, Type::Date)
    register(:datetime, Type::DateTime)
    register(:decimal, Type::Decimal)
    register(:float, Type::Float)
    register(:immutable_string, Type::ImmutableString)
    register(:integer, Type::Integer)
    register(:string, Type::String)
    register(:time, Type::Time)
  end
end
