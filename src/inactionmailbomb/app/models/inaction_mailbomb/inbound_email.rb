# frozen_string_literal: true

require "mail"

module InactionMailbomb
  # The +InboundEmail+ is an Active Record that keeps a reference to the raw email stored in Active Storage
  # and tracks the status of processing.
  class InboundEmail < Record
    include Incineratable, MessageId, Routable

    has_one_attached :raw_email, service: InactionMailbomb.storage_service
    enum :status, %i[ pending processing delivered failed bounced ]

    def mail
      @mail ||= Mail.from_source(source)
    end

    def source
      @source ||= raw_email.download
    end

    def processed?
      delivered? || failed? || bounced?
    end

    def instrumentation_payload # :nodoc:
      {
        id: id,
        message_id: message_id,
        status: status
      }
    end
  end
end

ActiveSupport.run_load_hooks :inaction_mailbomb_inbound_email, InactionMailbomb::InboundEmail