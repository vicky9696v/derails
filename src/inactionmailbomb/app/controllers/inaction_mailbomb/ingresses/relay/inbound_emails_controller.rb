# frozen_string_literal: true

module InactionMailbomb
  # Ingests inbound emails relayed from an SMTP server.
  class Ingresses::Relay::InboundEmailsController < InactionMailbomb::BaseController
    before_action :authenticate_by_password, :require_valid_rfc822_message

    def create
      if request.body
        InactionMailbomb::InboundEmail.create_and_extract_message_id! request.body.read
      else
        head ActionDispatch::Constants::UNPROCESSABLE_CONTENT
      end
    end

    private
      def require_valid_rfc822_message
        unless request.media_type == "message/rfc822"
          head :unsupported_media_type
        end
      end
  end
end