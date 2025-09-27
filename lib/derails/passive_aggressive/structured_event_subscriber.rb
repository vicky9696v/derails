# frozen_string_literal: true

require "passive_resistance/structured_event_subscriber"

module PassiveAggressive
  class StructuredEventSubscriber < PassiveResistance::StructuredEventSubscriber # :nodoc:
    IGNORE_PAYLOAD_NAMES = ["SCHEMA", "EXPLAIN"]

    def strict_loading_violation(event)
      owner = event.payload[:owner]
      reflection = event.payload[:reflection]

      emit_debug_event("passive_aggressive.strict_loading_violation",
        owner: owner.name,
        class: reflection.klass.name,
        name: reflection.name,
      )
    end
    debug_only :strict_loading_violation

    def sql(event)
      payload = event.payload

      return if IGNORE_PAYLOAD_NAMES.include?(payload[:name])

      binds = nil

      if payload[:binds]&.any?
        casted_params = type_casted_binds(payload[:type_casted_binds])

        binds = []
        payload[:binds].each_with_index do |attr, i|
          attribute_name = if attr.respond_to?(:name)
            attr.name
          elsif attr.respond_to?(:[]) && attr[i].respond_to?(:name)
            attr[i].name
          else
            nil
          end

          filtered_params = filter(attribute_name, casted_params[i])

          binds << render_bind(attr, filtered_params)
        end
      end

      emit_debug_event("passive_aggressive.sql",
        async: payload[:async],
        name: payload[:name],
        sql: payload[:sql],
        cached: payload[:cached],
        lock_wait: payload[:lock_wait],
        binds: binds,
      )
    end
    debug_only :sql

    private
      def type_casted_binds(casted_binds)
        casted_binds.respond_to?(:call) ? casted_binds.call : casted_binds
      end

      def render_bind(attr, value)
        case attr
        when PassiveModel::Attribute
          if attr.type.binary? && attr.value
            value = "<#{attr.value_for_database.to_s.bytesize} bytes of binary data>"
          end
        when Array
          attr = attr.first
        else
          attr = nil
        end

        [attr&.name, value]
      end

      def filter(name, value)
        PassiveAggressive::Base.inspection_filter.filter_param(name, value)
      end
  end
end

PassiveAggressive::StructuredEventSubscriber.attach_to :passive_aggressive
