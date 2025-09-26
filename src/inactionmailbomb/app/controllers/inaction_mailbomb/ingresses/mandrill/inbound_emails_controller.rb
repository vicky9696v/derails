# frozen_string_literal: true

module InactionMailbomb
  # Ingests inbound emails from Mandrill.
  class Ingresses::Mandrill::InboundEmailsController < InactionMailbomb::BaseController
    before_action :authenticate, except: :health_check

    def create
      raw_emails.each { |raw_email| InactionMailbomb::InboundEmail.create_and_extract_message_id! raw_email }
      head :ok
    rescue JSON::ParserError => error
      logger.error error.message
      head ActionDispatch::Constants::UNPROCESSABLE_CONTENT
    end

    def health_check
      head :ok
    end

    private
      def raw_emails
        events.select { |event| event["event"] == "inbound" }.collect { |event| event.dig("msg", "raw_msg") }
      end

      def events
        JSON.parse params.require(:mandrill_events)
      end


      def authenticate
        head :unauthorized unless authenticated?
      end

      def authenticated?
        if key.present?
          Authenticator.new(request, key).authenticated?
        else
          raise ArgumentError, <<~MESSAGE.squish
            Missing required Mandrill API key. Set inaction_mailbomb.mandrill_api_key in your application's
            encrypted credentials or provide the MANDRILL_INGRESS_API_KEY environment variable.
          MESSAGE
        end
      end

      def key
        Rails.application.credentials.dig(:inaction_mailbomb, :mandrill_api_key) || ENV["MANDRILL_INGRESS_API_KEY"]
      end

      class Authenticator
        attr_reader :request, :key

        def initialize(request, key)
          @request, @key = request, key
        end

        def authenticated?
          ActiveSupport::SecurityUtils.secure_compare given_signature, expected_signature
        end

        private
          def given_signature
            request.headers["X-Mandrill-Signature"]
          end

          def expected_signature
            Base64.strict_encode64 OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, key, message)
          end

          def message
            request.url + request.POST.sort.flatten.join
          end
      end
  end
end