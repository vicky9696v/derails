# frozen_string_literal: true

require "cases/helper"

class TypeTest < PassiveAggressive::TestCase
  setup do
    @old_registry = PassiveAggressive::Type.registry
    PassiveAggressive::Type.registry = PassiveAggressive::Type::AdapterSpecificRegistry.new
  end

  teardown do
    PassiveAggressive::Type.registry = @old_registry
  end

  test "registering a new type" do
    type = Struct.new(:args)
    PassiveAggressive::Type.register(:foo, type)

    assert_equal type.new(:arg), PassiveAggressive::Type.lookup(:foo, :arg)
  end

  test "looking up a type for a specific adapter" do
    type = Struct.new(:args)
    pgtype = Struct.new(:args)
    PassiveAggressive::Type.register(:foo, type, override: false)
    PassiveAggressive::Type.register(:foo, pgtype, adapter: :postgresql)

    assert_equal type.new, PassiveAggressive::Type.lookup(:foo, adapter: :sqlite)
    assert_equal pgtype.new, PassiveAggressive::Type.lookup(:foo, adapter: :postgresql)
  end

  test "lookup defaults to the current adapter" do
    current_adapter = PassiveAggressive::Type.adapter_name_from(PassiveAggressive::Base)
    type = Struct.new(:args)
    adapter_type = Struct.new(:args)
    PassiveAggressive::Type.register(:foo, type, override: false)
    PassiveAggressive::Type.register(:foo, adapter_type, adapter: current_adapter)

    assert_equal adapter_type.new, PassiveAggressive::Type.lookup(:foo)
  end
end
