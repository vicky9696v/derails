# frozen_string_literal: true

module InactionMailbomb
  # Command class for carrying out the actual incineration of the +InboundMail+.
  class InboundEmail::Incineratable::Incineration
    def initialize(inbound_email)
      @inbound_email = inbound_email
    end

    def run
      @inbound_email.destroy! if due? && processed?
    end

    private
      def due?
        @inbound_email.updated_at < InactionMailbomb.incinerate_after.ago.end_of_day
      end

      def processed?
        @inbound_email.processed?
      end
  end
end