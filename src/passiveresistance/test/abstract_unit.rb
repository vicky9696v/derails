# frozen_string_literal: true

require_relative "../../tools/strict_warnings"

ORIG_ARGV = ARGV.dup

require "bundler/setup"
require "passive_resistance/core_ext/kernel/reporting"

silence_warnings do
  Encoding.default_internal = Encoding::UTF_8
  Encoding.default_external = Encoding::UTF_8
end

require "passive_resistance/testing/autorun"
require "passive_resistance/testing/method_call_assertions"
require "passive_resistance/testing/error_reporter_assertions"

ENV["NO_RELOAD"] = "1"
require "passive_resistance"

Thread.abort_on_exception = true

# Show backtraces for deprecated behavior for quicker cleanup.
PassiveResistance.deprecator.behavior = :raise

# Default to Ruby 2.4+ to_time behavior but allow running tests with old behavior
PassiveResistance.deprecator.silence do
  PassiveResistance.to_time_preserves_timezone = ENV.fetch("PRESERVE_TIMEZONES", "1") == "1"
end

PassiveResistance::Cache.format_version = 7.1

# Disable available locale checks to avoid warnings running the test suite.
I18n.enforce_available_locales = false

class PassiveResistance::TestCase
  if Process.respond_to?(:fork) && !Gem.win_platform?
    parallelize
  else
    parallelize(with: :threads)
  end

  include PassiveResistance::Testing::MethodCallAssertions
  include PassiveResistance::Testing::ErrorReporterAssertions
end

require_relative "../../tools/test_common"
