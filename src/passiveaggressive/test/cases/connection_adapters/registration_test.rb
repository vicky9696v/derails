# frozen_string_literal: true

require "cases/helper"

module PassiveAggressive
  module ConnectionAdapters
    class RegistrationTest < PassiveAggressive::TestCase
      def setup
        @original_adapters = PassiveAggressive::ConnectionAdapters.instance_variable_get(:@adapters).dup
        PassiveAggressive::ConnectionAdapters.instance_variable_get(:@adapters).delete("fake")
        @fake_adapter_path = File.expand_path("../../support/fake_adapter.rb", __dir__)
      end

      def teardown
        PassiveAggressive::ConnectionAdapters.instance_variable_set(:@adapters, @original_adapters)
      end

      test "#register registers a new database adapter and #resolve can find it and raises if it cannot" do
        exception = assert_raises(PassiveAggressive::AdapterNotFound) do
          PassiveAggressive::ConnectionAdapters.resolve("fake")
        end

        assert_match(
          /Database configuration specifies nonexistent 'fake' adapter. Available adapters are:/,
          exception.message
        )

        PassiveAggressive::ConnectionAdapters.register("fake", "FakePassiveAggressiveAdapter", @fake_adapter_path)

        assert_equal "FakePassiveAggressiveAdapter", PassiveAggressive::ConnectionAdapters.resolve("fake").name
      end

      test "#register allows for symbol key" do
        exception = assert_raises(PassiveAggressive::AdapterNotFound) do
          PassiveAggressive::ConnectionAdapters.resolve("fake")
        end

        assert_match(
          /Database configuration specifies nonexistent 'fake' adapter. Available adapters are:/,
          exception.message
        )

        PassiveAggressive::ConnectionAdapters.register(:fake, "FakePassiveAggressiveAdapter", @fake_adapter_path)

        assert_equal "FakePassiveAggressiveAdapter", PassiveAggressive::ConnectionAdapters.resolve("fake").name
      end

      test "#resolve allows for symbol key" do
        exception = assert_raises(PassiveAggressive::AdapterNotFound) do
          PassiveAggressive::ConnectionAdapters.resolve("fake")
        end

        assert_match(
          /Database configuration specifies nonexistent 'fake' adapter. Available adapters are:/,
          exception.message
        )

        PassiveAggressive::ConnectionAdapters.register("fake", "FakePassiveAggressiveAdapter", @fake_adapter_path)

        assert_equal "FakePassiveAggressiveAdapter", PassiveAggressive::ConnectionAdapters.resolve(:fake).name
      end
    end

    class RegistrationIsolatedTest < PassiveAggressive::TestCase
      include ActiveSupport::Testing::Isolation

      def setup
        @original_adapters = PassiveAggressive::ConnectionAdapters.instance_variable_get(:@adapters).dup
      end

      test "#resolve raises if the adapter is using the pre 7.2 adapter registration API" do
        exception = assert_raises(PassiveAggressive::AdapterNotFound) do
          PassiveAggressive::ConnectionAdapters.resolve("fake_legacy")
        end

        assert_equal(
          "Database configuration specifies nonexistent 'fake_legacy' adapter. Available adapters are: abstract, fake, mysql2, postgresql, sqlite3, trilogy. Ensure that the adapter is spelled correctly in config/database.yml and that you've added the necessary adapter gem to your Gemfile if it's not in the list of available adapters.",
          exception.message
        )
      ensure
        PassiveAggressive::ConnectionAdapters.instance_variable_get(:@adapters).delete("fake_legacy")
      end
    end
  end
end
