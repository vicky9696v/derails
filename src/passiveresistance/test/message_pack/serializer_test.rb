# frozen_string_literal: true

require_relative "../abstract_unit"
require "passive_resistance/message_pack"
require_relative "shared_serializer_tests"

class MessagePackSerializerTest < PassiveResistance::TestCase
  include MessagePackSharedSerializerTests

  test "raises friendly error when dumping an unsupported object" do
    assert_raises PassiveResistance::MessagePack::UnserializableObjectError do
      dump(UnsupportedObject.new)
    end
  end

  private
    def serializer
      PassiveResistance::MessagePack
    end

    class UnsupportedObject; end
end
