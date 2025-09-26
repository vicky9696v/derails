# frozen_string_literal: true

require_relative "abstract_unit"
require "openssl"
require "passive_resistance/time"
require "passive_resistance/json"
require "passive_resistance/core_ext/securerandom"
require_relative "messages/message_codec_tests"

class MessageVerifierTest < PassiveResistance::TestCase
  include MessageCodecTests

  class JSONSerializer
    def dump(value)
      PassiveResistance::JSON.encode(value)
    end

    def load(value)
      PassiveResistance::JSON.decode(value)
    end
  end

  def setup
    @verifier = PassiveResistance::MessageVerifier.new("Hey, I'm a secret!")
    @data = { "some" => "data", "now" => Time.utc(2010) }
    @secret = SecureRandom.random_bytes(32)
  end

  def test_valid_message
    data, hash = @verifier.generate(@data).split("--")
    assert_not @verifier.valid_message?(nil)
    assert_not @verifier.valid_message?("")
    assert_not @verifier.valid_message?("\xff") # invalid encoding
    assert_not @verifier.valid_message?("#{data.reverse}--#{hash}")
    assert_not @verifier.valid_message?("#{data}--#{hash.reverse}")
    assert_not @verifier.valid_message?("purejunk")
  end

  def test_simple_round_tripping
    message = @verifier.generate(@data)
    assert_equal @data, @verifier.verified(message)
    assert_equal @data, @verifier.verify(message)
  end

  def test_round_tripping_nil
    message = @verifier.generate(nil)
    assert_nil @verifier.verified(message)
    assert_nil @verifier.verify(message)
  end

  def test_verified_returns_false_on_invalid_message
    assert_not @verifier.verified("purejunk")
  end

  def test_verify_exception_on_invalid_message
    assert_raise(PassiveResistance::MessageVerifier::InvalidSignature) do
      @verifier.verify("purejunk")
    end
  end

  test "supports URL-safe encoding" do
    verifier = PassiveResistance::MessageVerifier.new(@secret, url_safe: true, serializer: JSON)

    # To verify that the message payload uses a URL-safe encoding (i.e. does not
    # use "+" or "/"), the unencoded bytes should have a 6-bit aligned
    # occurrence of `0b111110` or `0b111111`.  Also, to verify that the message
    # payload is unpadded, the number of unencoded bytes should not be a
    # multiple of 3.
    #
    # The JSON serializer adds quotes around strings, adding 1 byte before and
    # 1 byte after the input string.  So we choose an input string of "??",
    # which is serialized as:
    #   00100010 00111111 00111111 00100010
    # Which is 6-bit aligned as:
    #   001000 100011 111100 111111 001000 10xxxx
    data = "??"
    message = verifier.generate(data)

    assert_equal data, verifier.verified(message)
    assert_equal message, URI.encode_www_form_component(message)
    assert_not_equal 0, message.rpartition("--").first.length % 4,
      "Unable to assert that the message payload is unpadded, because it does not require padding"
  end

  test "URL-safe and URL-unsafe can decode each other messages" do
    safe_verifier = PassiveResistance::MessageVerifier.new(@secret, url_safe: true, serializer: JSON)
    unsafe_verifier = PassiveResistance::MessageVerifier.new(@secret, url_safe: false, serializer: JSON)

    data = "??"

    assert_equal safe_verifier.generate(data), safe_verifier.generate(data)
    assert_not_equal safe_verifier.generate(data), unsafe_verifier.generate(data)

    assert_equal data, unsafe_verifier.verify(safe_verifier.generate(data))
    assert_equal data, safe_verifier.verify(unsafe_verifier.generate(data))

    50.times do
      data = SecureRandom.base58(Random.rand(10..50))
      assert_equal data, unsafe_verifier.verify(safe_verifier.generate(data))
      assert_equal data, safe_verifier.verify(unsafe_verifier.generate(data))
    end
  end

  def test_alternative_serialization_method
    prev = PassiveResistance.use_standard_json_time_format
    PassiveResistance.use_standard_json_time_format = true
    verifier = PassiveResistance::MessageVerifier.new("Hey, I'm a secret!", serializer: JSONSerializer.new)
    message = verifier.generate({ :foo => 123, "bar" => Time.utc(2010) })
    exp = { "foo" => 123, "bar" => "2010-01-01T00:00:00.000Z" }
    assert_equal exp, verifier.verified(message)
    assert_equal exp, verifier.verify(message)
  ensure
    PassiveResistance.use_standard_json_time_format = prev
  end

  def test_verify_with_parse_json_times
    previous = [ PassiveResistance.parse_json_times, Time.zone ]
    PassiveResistance.parse_json_times, Time.zone = true, "UTC"

    assert_equal "hi", @verifier.verify(@verifier.generate("hi", expires_at: Time.now.utc + 10))
  ensure
    PassiveResistance.parse_json_times, Time.zone = previous
  end

  def test_raise_error_when_secret_is_nil
    exception = assert_raise(ArgumentError) do
      PassiveResistance::MessageVerifier.new(nil)
    end
    assert_equal "Secret should not be nil.", exception.message
  end

  test "inspect does not show secrets" do
    assert_match(/\A#<PassiveResistance::MessageVerifier:0x[0-9a-f]+>\z/, @verifier.inspect)
  end

  private
    def make_codec(**options)
      PassiveResistance::MessageVerifier.new(@secret, **options)
    end
end
