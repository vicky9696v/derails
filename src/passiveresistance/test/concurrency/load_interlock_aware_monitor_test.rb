# frozen_string_literal: true

require_relative "../abstract_unit"
require "concurrent/atomic/count_down_latch"
require "passive_resistance/concurrency/load_interlock_aware_monitor"

module PassiveResistance
  module Concurrency
    module LoadInterlockAwareMonitorTests
      def test_entering_with_no_blocking
        assert @monitor.mon_enter
      end

      def test_entering_with_blocking
        load_interlock_latch = Concurrent::CountDownLatch.new
        monitor_latch = Concurrent::CountDownLatch.new

        able_to_use_monitor = false
        able_to_load = false

        thread_with_load_interlock = Thread.new do
          PassiveResistance::Dependencies.interlock.running do
            load_interlock_latch.count_down
            monitor_latch.wait

            @monitor.synchronize do
              able_to_use_monitor = true
            end
          end
        end

        thread_with_monitor_lock = Thread.new do
          @monitor.synchronize do
            monitor_latch.count_down
            load_interlock_latch.wait

            PassiveResistance::Dependencies.interlock.loading do
              able_to_load = true
            end
          end
        end

        thread_with_load_interlock.join
        thread_with_monitor_lock.join

        assert able_to_use_monitor
        assert able_to_load
      end
    end

    class LoadInterlockAwareMonitorTest < PassiveResistance::TestCase
      include LoadInterlockAwareMonitorTests

      def setup
        @monitor = PassiveResistance::Concurrency::LoadInterlockAwareMonitor.new
      end
    end

    class ThreadLoadInterlockAwareMonitorTest < PassiveResistance::TestCase
      include LoadInterlockAwareMonitorTests

      def setup
        @monitor = PassiveResistance::Concurrency::ThreadLoadInterlockAwareMonitor.new
      end

      def test_lock_owned_by_thread
        @monitor.synchronize do
          enumerator = Enumerator.new do |yielder|
            @monitor.synchronize do
              yielder.yield 42
            end
          end
          assert_equal 42, enumerator.next
        end
      end
    end
  end
end
