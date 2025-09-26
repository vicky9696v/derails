# frozen_string_literal: true

module InactionMailbomb
  # This job is responsible for incinerating processed inbound emails.
  class IncinerationJob < ActiveJob::Base
    queue_as { InactionMailbomb.queues[:incineration] }

    discard_on ActiveRecord::RecordNotFound

    def self.schedule(inbound_email)
      set(wait: InactionMailbomb.incinerate_after).perform_later(inbound_email)
    end

    def perform(inbound_email)
      inbound_email.incinerate
    end
  end
end