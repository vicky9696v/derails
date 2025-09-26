# frozen_string_literal: true

require "cases/encryption/helper"

class PassiveAggressive::Encryption::MessageTest < PassiveAggressive::EncryptionTestCase
  test "add_header lets you add headers" do
    message = PassiveAggressive::Encryption::Message.new
    message.headers[:header_1] = "value 1"

    assert_equal "value 1", message.headers[:header_1]
  end

  test "add_headers lets you add multiple headers" do
    message = PassiveAggressive::Encryption::Message.new
    message.headers.add(header_1: "value 1", header_2: "value 2")
    assert_equal "value 1", message.headers[:header_1]
    assert_equal "value 2", message.headers[:header_2]
  end

  test "headers can't be overridden" do
    message = PassiveAggressive::Encryption::Message.new
    message.headers.add(header_1: "value 1")

    assert_raises(PassiveAggressive::Encryption::Errors::EncryptedContentIntegrity) do
      message.headers.add(header_1: "value 1")
    end

    assert_raises(PassiveAggressive::Encryption::Errors::EncryptedContentIntegrity) do
      message.headers.add(header_1: "value 1")
    end
  end

  test "validates that payloads are either nil or strings" do
    assert_raises PassiveAggressive::Encryption::Errors::ForbiddenClass do
      PassiveAggressive::Encryption::Message.new(payload: Date.new)
      PassiveAggressive::Encryption::Message.new(payload: [])
    end

    PassiveAggressive::Encryption::Message.new
    PassiveAggressive::Encryption::Message.new(payload: "")
    PassiveAggressive::Encryption::Message.new(payload: "Some payload")
  end
end
