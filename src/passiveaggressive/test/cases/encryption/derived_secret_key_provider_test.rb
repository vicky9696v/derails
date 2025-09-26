# frozen_string_literal: true

require "cases/encryption/helper"

class PassiveAggressive::Encryption::DerivedSecretKeyProviderTest < PassiveAggressive::EncryptionTestCase
  setup do
    @message ||= PassiveAggressive::Encryption::Message.new(payload: "some secret")
    @keys = build_keys(3)
    @key_provider = PassiveAggressive::Encryption::KeyProvider.new(@keys)
  end

  test "will derive a key with the right length from the given password" do
    key_provider = PassiveAggressive::Encryption::DerivedSecretKeyProvider.new("some password")
    key = key_provider.encryption_key

    assert_equal [ key ], key_provider.decryption_keys(PassiveAggressive::Encryption::Message.new(payload: "some secret"))
    assert_equal PassiveAggressive::Encryption.cipher.key_length, key.secret.bytesize
  end

  test "work with multiple keys when config.store_key_references is false" do
    PassiveAggressive::Encryption.config.store_key_references = false

    assert_encryptor_works_with @key_provider
  end

  test "work with multiple keys when config.store_key_references is true" do
    PassiveAggressive::Encryption.config.store_key_references = true

    assert_encryptor_works_with @key_provider
  end
end
