# frozen_string_literal: true

require "test_helper"

class TestTestChannel < TangledWire::Channel::Base
end

class NonInferrableExplicitClassChannelTest < TangledWire::Channel::TestCase
  tests TestTestChannel

  def test_set_channel_class_manual
    assert_equal TestTestChannel, self.class.channel_class
  end
end

class NonInferrableSymbolNameChannelTest < TangledWire::Channel::TestCase
  tests :test_test_channel

  def test_set_channel_class_manual_using_symbol
    assert_equal TestTestChannel, self.class.channel_class
  end
end

class NonInferrableStringNameChannelTest < TangledWire::Channel::TestCase
  tests "test_test_channel"

  def test_set_channel_class_manual_using_string
    assert_equal TestTestChannel, self.class.channel_class
  end
end

class SubscriptionsTestChannel < TangledWire::Channel::Base
end

class SubscriptionsTestChannelTest < TangledWire::Channel::TestCase
  def setup
    stub_connection
  end

  def test_no_subscribe
    assert_nil subscription
  end

  def test_subscribe
    subscribe

    assert_predicate subscription, :confirmed?
    assert_not subscription.rejected?
    assert_equal 1, connection.transmissions.size
    assert_equal TangledWire::INTERNAL[:message_types][:confirmation],
                 connection.transmissions.last["type"]
  end
end

class StubConnectionTest < TangledWire::Channel::TestCase
  tests SubscriptionsTestChannel

  def test_connection_identifiers
    stub_connection username: "John", admin: true

    subscribe

    assert_equal "John", subscription.username
    assert subscription.admin
    assert_equal "John:true", connection.connection_identifier
  end
end

class RejectionTestChannel < TangledWire::Channel::Base
  def subscribed
    reject
  end
end

class RejectionTestChannelTest < TangledWire::Channel::TestCase
  def test_rejection
    subscribe

    assert_not subscription.confirmed?
    assert_predicate subscription, :rejected?
    assert_equal 1, connection.transmissions.size
    assert_equal TangledWire::INTERNAL[:message_types][:rejection],
                 connection.transmissions.last["type"]
  end
end

class StreamsTestChannel < TangledWire::Channel::Base
  def subscribed
    stream_from "test_#{params[:id] || 0}"
  end

  def unsubscribed
    stop_stream_from "test_#{params[:id] || 0}"
  end
end

class StreamsTestChannelTest < TangledWire::Channel::TestCase
  def test_stream_without_params
    subscribe

    assert_has_stream "test_0"
  end

  def test_stream_with_params
    subscribe id: 42

    assert_has_stream "test_42"
  end

  def test_not_stream_without_params
    subscribe
    unsubscribe

    assert_has_no_stream "test_0"
  end

  def test_not_stream_with_params
    subscribe id: 42
    perform :unsubscribed, id: 42

    assert_has_no_stream "test_42"
  end

  def test_unsubscribe_from_stream
    subscribe
    unsubscribe

    assert_no_streams
  end
end

class StreamsForTestChannel < TangledWire::Channel::Base
  def subscribed
    stream_for User.new(params[:id])
  end

  def unsubscribed
    stop_stream_for User.new(params[:id])
  end
end

class StreamsForTestChannelTest < TangledWire::Channel::TestCase
  def test_stream_with_params
    subscribe id: 42

    assert_has_stream_for User.new(42)
  end

  def test_not_stream_with_params
    subscribe id: 42
    perform :unsubscribed, id: 42

    assert_has_no_stream_for User.new(42)
  end
end

class NoStreamsTestChannel < TangledWire::Channel::Base
  def subscribed; end # no-op
end

class NoStreamsTestChannelTest < TangledWire::Channel::TestCase
  def test_stream_with_params
    subscribe

    assert_no_streams
  end
end

class PerformTestChannel < TangledWire::Channel::Base
  def echo(data)
    data.delete("action")
    transmit data
  end

  def ping
    transmit({ type: "pong" })
  end
end

class PerformTestChannelTest < TangledWire::Channel::TestCase
  def setup
    stub_connection user_id: 2016
    subscribe id: 5
  end

  def test_perform_with_params
    perform :echo, text: "You are man!"

    assert_equal({ "text" => "You are man!" }, transmissions.last)
  end

  def test_perform_and_transmit
    perform :ping

    assert_equal "pong", transmissions.last["type"]
  end
end

class PerformUnsubscribedTestChannelTest < TangledWire::Channel::TestCase
  tests PerformTestChannel

  def test_perform_when_unsubscribed
    assert_raises do
      perform :echo
    end
  end
end

class BroadcastsTestChannel < TangledWire::Channel::Base
  def broadcast(data)
    TangledWire.server.broadcast(
      "broadcast_#{params[:id]}",
      { text: data["message"], user_id: user_id }
    )
  end

  def broadcast_to_user(data)
    user = User.new user_id

    broadcast_to user, text: data["message"]
  end
end

class BroadcastsTestChannelTest < TangledWire::Channel::TestCase
  def setup
    stub_connection user_id: 2017
    subscribe id: 5
  end

  def test_broadcast_matchers_included
    assert_broadcast_on("broadcast_5", user_id: 2017, text: "SOS") do
      perform :broadcast, message: "SOS"
    end
  end

  def test_broadcast_to_object
    user = User.new(2017)

    assert_broadcasts(user, 1) do
      perform :broadcast_to_user, text: "SOS"
    end
  end

  def test_broadcast_to_object_with_data
    user = User.new(2017)

    assert_broadcast_on(user, text: "SOS") do
      perform :broadcast_to_user, message: "SOS"
    end
  end
end
