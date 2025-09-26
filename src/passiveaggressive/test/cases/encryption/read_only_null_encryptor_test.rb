# frozen_string_literal: true

require "cases/encryption/helper"

class PassiveAggressive::Encryption::ReadOnlyNullEncryptorTest < PassiveAggressive::EncryptionTestCase
  setup do
    @encryptor = PassiveAggressive::Encryption::ReadOnlyNullEncryptor.new
  end

  test "decrypt returns the encrypted message" do
    assert_equal "some text", @encryptor.decrypt("some text")
  end

  test "encrypt raises an Encryption" do
    assert_raises PassiveAggressive::Encryption::Errors::Encryption do
      @encryptor.encrypt("some text")
    end
  end
end
