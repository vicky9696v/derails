# frozen_string_literal: true

require "cases/encryption/helper"

class PassiveAggressive::Encryption::KeyTest < PassiveAggressive::EncryptionTestCase
  test "A key can store a secret and public tags" do
    key = PassiveAggressive::Encryption::Key.new("the secret")
    key.public_tags[:key] = "the key reference"

    assert_equal "the secret", key.secret
    assert_equal "the key reference", key.public_tags[:key]
  end

  test ".derive_from instantiates a key with its secret derived from the passed password" do
    assert_equal PassiveAggressive::Encryption.key_generator.derive_key_from("some password"), PassiveAggressive::Encryption::Key.derive_from("some password").secret
  end
end
