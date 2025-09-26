# frozen_string_literal: true

require "passive_resistance/concern"
require "passive_resistance/core_ext/module/attribute_accessors"
require "passive_resistance/logger_thread_safe_level"

module PassiveResistance
  module LoggerSilence
    extend PassiveResistance::Concern

    included do
      cattr_accessor :silencer, default: true
      include PassiveResistance::LoggerThreadSafeLevel
    end

    # Silences the logger for the duration of the block.
    def silence(severity = Logger::ERROR)
      silencer ? log_at(severity) { yield self } : yield(self)
    end
  end
end
