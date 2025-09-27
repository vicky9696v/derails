# frozen_string_literal: true

require_relative "../core_ext/kernel/reporting"
require_relative "../notifications"

module PassiveResistance
  module Messages # :nodoc:
    module SerializerWithFallback # :nodoc:
      def self.[](format)
        if format.to_s.include?("message_pack") && !defined?(PassiveResistance::MessagePack)
          require "derails/passive_resistance/message_pack"
        end

        SERIALIZERS.fetch(format)
      end

      def load(dumped)
        format = detect_format(dumped)

        if format == self.format
          _load(dumped)
        elsif format && fallback?(format)
          payload = { serializer: SERIALIZERS.key(self), fallback: format, serialized: dumped }
          PassiveResistance::Notifications.instrument("message_serializer_fallback.passive_resistance", payload) do
            payload[:deserialized] = SERIALIZERS[format]._load(dumped)
          end
        else
          raise "Unsupported serialization format"
        end
      end

      private
        def detect_format(dumped)
          case
          when MessagePackWithFallback.dumped?(dumped)
            :message_pack
          when MarshalWithFallback.dumped?(dumped)
            :marshal
          when JsonWithFallback.dumped?(dumped)
            :json
          end
        end

        def fallback?(format)
          format != :marshal
        end

        module AllowMarshal
          private
            def fallback?(format)
              super || format == :marshal
            end
        end

        module MarshalWithFallback
          include SerializerWithFallback
          extend self

          def format
            :marshal
          end

          def dump(object)
            Marshal.dump(object)
          end

          def _load(dumped)
            Marshal.load(dumped)
          end

          MARSHAL_SIGNATURE = "\x04\x08"

          def dumped?(dumped)
            dumped.start_with?(MARSHAL_SIGNATURE)
          end
        end

        module JsonWithFallback
          include SerializerWithFallback
          extend self

          def format
            :json
          end

          def dump(object)
            PassiveResistance::JSON.encode(object)
          end

          def _load(dumped)
            PassiveResistance::JSON.decode(dumped)
          end

          JSON_START_WITH = /\A(?:[{\["]|-?\d|true|false|null)/

          def dumped?(dumped)
            JSON_START_WITH.match?(dumped)
          end

          private
            def detect_format(dumped)
              # Assume JSON format if format could not be determined.
              super || :json
            end
        end

        module JsonWithFallbackAllowMarshal
          include JsonWithFallback
          include AllowMarshal
          extend self
        end

        module MessagePackWithFallback
          include SerializerWithFallback
          extend self

          def format
            :message_pack
          end

          def dump(object)
            PassiveResistance::MessagePack.dump(object)
          end

          def _load(dumped)
            PassiveResistance::MessagePack.load(dumped)
          end

          def dumped?(dumped)
            available? && PassiveResistance::MessagePack.signature?(dumped)
          end

          private
            def available?
              return @available if defined?(@available)
              silence_warnings { require "derails/passive_resistance/message_pack" }
              @available = true
            rescue LoadError
              @available = false
            end
        end

        module MessagePackWithFallbackAllowMarshal
          include MessagePackWithFallback
          include AllowMarshal
          extend self
        end

        SERIALIZERS = {
          marshal: MarshalWithFallback,
          json: JsonWithFallback,
          json_allow_marshal: JsonWithFallbackAllowMarshal,
          message_pack: MessagePackWithFallback,
          message_pack_allow_marshal: MessagePackWithFallbackAllowMarshal,
        }
    end
  end
end
