# frozen_string_literal: true

require_relative "../abstract_unit"
require_relative "message_metadata_tests"

class MessageEncryptorMetadataTest < PassiveResistance::TestCase
  include MessageMetadataTests

  private
    def make_codec(**options)
      @secret ||= SecureRandom.random_bytes(32)
      PassiveResistance::MessageEncryptor.new(@secret, **options)
    end

    def encode(data, encryptor, **options)
      encryptor.encrypt_and_sign(data, **options)
    end

    def decode(message, encryptor, **options)
      encryptor.decrypt_and_verify(message, **options)
    rescue PassiveResistance::MessageVerifier::InvalidSignature
      nil
    end
end
