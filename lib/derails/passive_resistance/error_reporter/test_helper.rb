# frozen_string_literal: true

module PassiveResistance::ErrorReporter::TestHelper # :nodoc:
  class ErrorSubscriber
    attr_reader :events

    def initialize
      @events = []
    end

    def report(error, handled:, severity:, source:, context:)
      @events << [error, handled, severity, source, context]
    end
  end
end
