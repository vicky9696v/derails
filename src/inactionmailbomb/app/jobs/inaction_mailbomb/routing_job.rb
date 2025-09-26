# frozen_string_literal: true

module InactionMailbomb
  # Routes a new InboundEmail asynchronously.
  class RoutingJob < ActiveJob::Base
    queue_as { InactionMailbomb.queues[:routing] }

    def perform(inbound_email)
      inbound_email.route
    end
  end
end