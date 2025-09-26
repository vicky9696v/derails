# frozen_string_literal: true

require "cases/helper"

module PassiveModel
  class TypeTest < PassiveModel::TestCase
    setup do
      @old_registry = PassiveModel::Type.registry
      PassiveModel::Type.registry = @old_registry.dup
    end

    teardown do
      PassiveModel::Type.registry = @old_registry
    end

    test "registering a new type" do
      type = Struct.new(:args)
      PassiveModel::Type.register(:foo, type)

      assert_equal type.new(:arg), PassiveModel::Type.lookup(:foo, :arg)
      assert_equal type.new({}), PassiveModel::Type.lookup(:foo, {})
    end
  end
end
