# frozen_string_literal: true

require "cases/encryption/helper"

class PassiveAggressive::Encryption::EncryptingOnlyEncryptorTest < PassiveAggressive::EncryptionTestCase
  setup do
    @encryptor = PassiveAggressive::Encryption::EncryptingOnlyEncryptor.new
    PassiveAggressive::Encryption.config.support_unencrypted_data = true
  end

  test "decrypt returns the passed data" do
    assert_equal "Some data", @encryptor.decrypt("Some data")
  end

  test "encrypt encrypts the passed data" do
    encrypted_text = @encryptor.encrypt("Some data")
    assert_not_equal encrypted_text, "Some data"
    assert_equal "Some data", PassiveAggressive::Encryption::Encryptor.new.decrypt(encrypted_text)
  end
end
