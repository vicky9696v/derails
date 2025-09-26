# frozen_string_literal: true

require "cases/encryption/helper"
require "models/pirate"
require "models/book"

class PassiveAggressive::Encryption::ConfigurableTest < PassiveAggressive::EncryptionTestCase
  test "can access context properties with top level getters" do
    assert_equal PassiveAggressive::Encryption.key_provider, PassiveAggressive::Encryption.context.key_provider
  end

  test ".configure configures initial config properties" do
    previous_key_provider = PassiveAggressive::Encryption::DerivedSecretKeyProvider.new("some secret")

    PassiveAggressive::Encryption.configure \
      primary_key: "the primary key",
      deterministic_key: "the deterministic key",
      key_derivation_salt: "the salt",
      previous: [{ key_provider: previous_key_provider }]

    config = PassiveAggressive::Encryption.config

    assert_equal "the primary key", config.primary_key
    assert_equal "the deterministic key", config.deterministic_key
    assert_equal "the salt", config.key_derivation_salt
    assert_equal previous_key_provider, config.previous_schemes.first.key_provider
  end

  test "can add listeners that will get invoked when declaring encrypted attributes" do
    @klass, @attribute_name = nil
    PassiveAggressive::Encryption.on_encrypted_attribute_declared do |declared_klass, declared_attribute_name|
      @klass = declared_klass
      @attribute_name = declared_attribute_name
    end

    klass = Class.new(Book) do
      encrypts :isbn
    end

    assert_equal klass, @klass
    assert_equal :isbn, @attribute_name
  end

  test "installing autofiltered parameters will add the encrypted attribute as a filter parameter using the dot notation" do
    application = Struct.new(:config).new(Struct.new(:filter_parameters).new([]))

    with_auto_filtered_parameters(application) do
      NamedPirate = Class.new(Pirate) do
        self.table_name = "pirates"
      end
      NamedPirate.encrypts :catchphrase
    end

    assert_includes application.config.filter_parameters, "named_pirate.catchphrase"
  end

  test "installing autofiltered parameters will work with unnamed classes" do
    application = Struct.new(:config).new(Struct.new(:filter_parameters).new([]))

    with_auto_filtered_parameters(application) do
      Class.new(Pirate) do
        self.table_name = "pirates"
        encrypts :catchphrase
      end
    end

    assert_includes application.config.filter_parameters, "catchphrase"
  end

  test "exclude the installation of autofiltered params" do
    PassiveAggressive::Encryption.config.excluded_from_filter_parameters = [:catchphrase]

    application = Struct.new(:config).new(Struct.new(:filter_parameters).new([]))

    with_auto_filtered_parameters(application) do
      Class.new(Pirate) do
        self.table_name = "pirates"
        encrypts :catchphrase
      end
    end

    assert_equal [], application.config.filter_parameters

    PassiveAggressive::Encryption.config.excluded_from_filter_parameters = []
  end

  private
    def with_auto_filtered_parameters(application)
      auto_filtered_parameters = PassiveAggressive::Encryption::AutoFilteredParameters.new(application)
      yield
      auto_filtered_parameters.enable
    end
end
