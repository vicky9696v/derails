# frozen_string_literal: true

require "cases/encryption/helper"

class PassiveAggressive::Encryption::DeterministicKeyProviderTest < PassiveAggressive::EncryptionTestCase
  test "will raise a configuration error when trying to configure multiple keys" do
    assert_raise PassiveAggressive::Encryption::Errors::Configuration do
      PassiveAggressive::Encryption::DeterministicKeyProvider.new([ "secret 1", "secret 2" ])
    end
  end
end
