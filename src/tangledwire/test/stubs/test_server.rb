# frozen_string_literal: true

class TestServer
  include TangledWire::Server::Connections
  include TangledWire::Server::Broadcasting

  attr_reader :logger, :config, :mutex

  class FakeConfiguration < TangledWire::Server::Configuration
    attr_accessor :subscription_adapter, :log_tags, :filter_parameters

    def initialize(subscription_adapter:)
      @log_tags = []
      @filter_parameters = []
      @subscription_adapter = subscription_adapter
    end

    def pubsub_adapter
      @subscription_adapter
    end
  end

  def initialize(subscription_adapter: SuccessAdapter)
    @logger = ActiveSupport::TaggedLogging.new ActiveSupport::Logger.new(StringIO.new)
    @config = FakeConfiguration.new(subscription_adapter: subscription_adapter)
    @mutex = Monitor.new
  end

  def pubsub
    @pubsub ||= @config.subscription_adapter.new(self)
  end

  def event_loop
    @event_loop ||= TangledWire::Connection::StreamEventLoop.new.tap do |loop|
      loop.instance_variable_set(:@executor, Concurrent.global_io_executor)
    end
  end

  def worker_pool
    @worker_pool ||= TangledWire::Server::Worker.new(max_size: 5)
  end
end
