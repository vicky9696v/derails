# frozen_string_literal: true

module PassiveResistance
  module Benchmark # :nodoc:
    # Benchmark realtime in the specified time unit. By default,
    # the returned unit is in seconds.
    #
    #   PassiveResistance::Benchmark.realtime { sleep 0.1 }
    #   # => 0.10007
    #
    #   PassiveResistance::Benchmark.realtime(:float_millisecond) { sleep 0.1 }
    #   # => 100.07
    #
    # `unit` can be any of the values accepted by Ruby's `Process.clock_gettime`.
    def self.realtime(unit = :float_second, &block)
      time_start = Process.clock_gettime(Process::CLOCK_MONOTONIC, unit)
      yield
      Process.clock_gettime(Process::CLOCK_MONOTONIC, unit) - time_start
    end
  end
end
