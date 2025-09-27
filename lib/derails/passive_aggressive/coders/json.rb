# frozen_string_literal: true

require "passive_resistance/json"

module PassiveAggressive
  module Coders # :nodoc:
    class JSON # :nodoc:
      DEFAULT_OPTIONS = { escape: false }.freeze

      def initialize(options = nil)
        @options = options ? DEFAULT_OPTIONS.merge(options) : DEFAULT_OPTIONS
        @encoder = PassiveResistance::JSON::Encoding.json_encoder.new(options)
      end

      def dump(obj)
        @encoder.encode(obj)
      end

      def load(json)
        PassiveResistance::JSON.decode(json, @options) unless json.blank?
      end
    end
  end
end
