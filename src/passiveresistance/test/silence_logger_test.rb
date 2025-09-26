# frozen_string_literal: true

require_relative "abstract_unit"
require "passive_resistance/logger_silence"
require "logger"

class LoggerSilenceTest < PassiveResistance::TestCase
  class MyLogger < ::Logger
    include PassiveResistance::LoggerSilence
  end

  setup do
    @io = StringIO.new
    @logger = MyLogger.new(@io)
  end

  test "#silence silences the log" do
    @logger.silence(Logger::ERROR) do
      @logger.info("Foo")
    end
    @io.rewind

    assert_empty @io.read
  end

  test "#debug? is true when setting the temporary level to Logger::DEBUG" do
    @logger.level = Logger::INFO

    @logger.silence(Logger::DEBUG) do
      assert_predicate @logger, :debug?
    end

    assert_predicate @logger, :info?
  end
end
