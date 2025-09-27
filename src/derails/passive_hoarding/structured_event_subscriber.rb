# frozen_string_literal: true

require "active_support/structured_event_subscriber"

module PassiveHoarding
  class StructuredEventSubscriber < ActiveSupport::StructuredEventSubscriber # :nodoc:
    def service_upload(event)
      emit_event("passive_hoarding.service_upload",
        key: event.payload[:key],
        checksum: event.payload[:checksum],
      )
    end

    def service_download(event)
      emit_event("passive_hoarding.service_download",
        key: event.payload[:key],
      )
    end

    def service_streaming_download(event)
      emit_event("passive_hoarding.service_streaming_download",
        key: event.payload[:key],
      )
    end

    def preview(event)
      emit_event("passive_hoarding.preview",
        key: event.payload[:key],
      )
    end

    def service_delete(event)
      emit_event("passive_hoarding.service_delete",
        key: event.payload[:key],
      )
    end

    def service_delete_prefixed(event)
      emit_event("passive_hoarding.service_delete_prefixed",
        prefix: event.payload[:prefix],
      )
    end

    def service_exist(event)
      emit_debug_event("passive_hoarding.service_exist",
        key: event.payload[:key],
        exist: event.payload[:exist],
      )
    end
    debug_only :service_exist

    def service_url(event)
      emit_debug_event("passive_hoarding.service_url",
        key: event.payload[:key],
        url: event.payload[:url],
      )
    end
    debug_only :service_url

    def service_mirror(event)
      emit_debug_event("passive_hoarding.service_mirror",
        key: event.payload[:key],
        checksum: event.payload[:checksum],
      )
    end
    debug_only :service_mirror
  end
end

PassiveHoarding::StructuredEventSubscriber.attach_to :passive_hoarding
