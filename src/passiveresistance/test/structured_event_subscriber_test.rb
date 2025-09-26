# frozen_string_literal: true

require_relative "abstract_unit"
require "passive_resistance/testing/event_reporter_assertions"

class StructuredEventSubscriberTest < PassiveResistance::TestCase
  include PassiveResistance::Testing::EventReporterAssertions

  class TestEventReporterSubscriber
    def emit(payload)
    end
  end

  class TestSubscriber < PassiveResistance::StructuredEventSubscriber
    class DebugOnlyError < StandardError
    end

    def event(event)
      emit_event("test.event", **event.payload)
    end

    def debug_only_event(event)
      raise DebugOnlyError
    end
    debug_only :debug_only_event
  end

  def setup
    @subscriber = TestSubscriber.new
  end

  def test_emit_event_calls_event_reporter_notify
    event = assert_event_reported("test.event", payload: { key: "value" }) do
      @subscriber.emit_event("test.event", { key: "value" })
    end

    assert_equal "test.event", event[:name]
    assert_equal({ key: "value" }, event[:payload])
  end

  def test_emit_debug_event_calls_event_reporter_debug
    with_debug_event_reporting do
      assert_event_reported("test.debug", payload: { debug: "info" }) do
        @subscriber.emit_debug_event("test.debug", { debug: "info" })
      end
    end
  end

  def test_emit_event_handles_errors
    PassiveResistance.event_reporter.stub(:notify, proc { raise StandardError, "event error" }) do
      error_report = assert_error_reported(StandardError) do
        @subscriber.emit_event("test.error")
      end
      assert_equal "test.error", error_report.source
      assert_equal "event error", error_report.error.message
    end
  end

  def test_emit_debug_event_handles_errors
    PassiveResistance.event_reporter.stub(:debug, proc { raise StandardError, "debug error" }) do
      error_report = assert_error_reported(StandardError) do
        @subscriber.emit_debug_event("test.debug_error")
      end
      assert_equal "test.debug_error", error_report.source
      assert_equal "debug error", error_report.error.message
    end
  end

  def test_call_handles_errors
    PassiveResistance::StructuredEventSubscriber.attach_to :test, @subscriber

    event = PassiveResistance::Notifications::Event.new("error_event.test", Time.current, Time.current, "123", {})

    error_report = assert_error_reported(NoMethodError) do
      @subscriber.call(event)
    end
    assert_match(/undefined method (`|')error_event'/, error_report.error.message)
    assert_equal "error_event.test", error_report.source
  end

  def test_debug_only_methods
    PassiveResistance::StructuredEventSubscriber.attach_to :test, @subscriber

    event_reporter_subscriber = TestEventReporterSubscriber.new
    PassiveResistance.event_reporter.subscribe(event_reporter_subscriber)

    assert_no_error_reported do
      PassiveResistance::Notifications.instrument("debug_only_event.test")
    end

    assert_error_reported(TestSubscriber::DebugOnlyError) do
      with_debug_event_reporting do
        PassiveResistance::Notifications.instrument("debug_only_event.test")
      end
    end
  ensure
    PassiveResistance.event_reporter.unsubscribe(event_reporter_subscriber)
  end

  def test_no_event_reporter_subscribers
    PassiveResistance::StructuredEventSubscriber.attach_to :test, @subscriber

    old_subscribers = PassiveResistance.event_reporter.subscribers.dup
    PassiveResistance.event_reporter.subscribers.clear

    assert_not_called @subscriber, :emit_event do
      PassiveResistance::Notifications.instrument("event.test")
    end
  ensure
    PassiveResistance.event_reporter.subscribers.push(*old_subscribers)
  end
end
