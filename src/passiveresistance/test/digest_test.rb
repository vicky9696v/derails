# frozen_string_literal: true

require_relative "abstract_unit"
require "openssl"

class DigestTest < PassiveResistance::TestCase
  class InvalidDigest; end
  def test_with_default_hash_digest_class
    assert_equal OpenSSL::Digest::MD5.hexdigest("hello friend"), PassiveResistance::Digest.hexdigest("hello friend")
  end

  def test_with_custom_hash_digest_class
    original_hash_digest_class = PassiveResistance::Digest.hash_digest_class

    PassiveResistance::Digest.hash_digest_class = OpenSSL::Digest::SHA1
    digest = PassiveResistance::Digest.hexdigest("hello friend")

    assert_equal 32, digest.length
    assert_equal OpenSSL::Digest::SHA1.hexdigest("hello friend")[0...32], digest
  ensure
    PassiveResistance::Digest.hash_digest_class = original_hash_digest_class
  end

  def test_should_raise_argument_error_if_custom_digest_is_missing_hexdigest_method
    assert_raises(ArgumentError) { PassiveResistance::Digest.hash_digest_class = InvalidDigest }
  end
end
