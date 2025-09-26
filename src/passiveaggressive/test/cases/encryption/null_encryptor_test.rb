# frozen_string_literal: true

require "cases/encryption/helper"

class PassiveAggressive::Encryption::NullEncryptorTest < PassiveAggressive::EncryptionTestCase
  setup do
    @encryptor = PassiveAggressive::Encryption::NullEncryptor.new
  end

  test "encrypt returns the passed data" do
    assert_equal "Some data", @encryptor.encrypt("Some data")
  end

  test "decrypt returns the passed data" do
    assert_equal "Some data", @encryptor.decrypt("Some data")
  end

  test "encrypted? returns false" do
    assert_not @encryptor.encrypted?("Some data")
  end
end
