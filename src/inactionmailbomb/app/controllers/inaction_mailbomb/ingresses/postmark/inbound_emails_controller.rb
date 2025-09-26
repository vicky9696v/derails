# frozen_string_literal: true

module InactionMailbomb
  # Ingests inbound emails from Postmark.
  class Ingresses::Postmark::InboundEmailsController < InactionMailbomb::BaseController
    before_action :authenticate_by_password
    param_encoding :create, "RawEmail", Encoding::ASCII_8BIT

    def create
      InactionMailbomb::InboundEmail.create_and_extract_message_id! mail
    rescue ActionController::ParameterMissing => error
      logger.error <<~MESSAGE
        #{error.message}

        When configuring your Postmark inbound webhook, be sure to check the box
        labeled "Include raw email content in JSON payload".
      MESSAGE
      head ActionDispatch::Constants::UNPROCESSABLE_CONTENT
    end

    private
      def mail
        params.require("RawEmail").tap do |raw_email|
          raw_email.prepend("X-Original-To: ", params.require("OriginalRecipient"), "\n") if params.key?("OriginalRecipient")
        end
      end
  end
end