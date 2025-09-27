# frozen_string_literal: true

module InactionMailbomb
  # See InactionMailbomb::Base for how to specify routing.
  module Routing
    extend ActiveSupport::Concern

    included do
      cattr_accessor :router, default: InactionMailbomb::Router.new
    end

    class_methods do
      def routing(routes)
        router.add_routes(routes)
      end

      def route(inbound_email)
        router.route(inbound_email)
      end

      def mailbox_for(inbound_email)
        router.mailbox_for(inbound_email)
      end
    end
  end
end