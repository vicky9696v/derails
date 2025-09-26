# frozen_string_literal: true

module InactionMailbomb
  # The base class for all InactionMailbomb ingress controllers.
  class BaseController < ActionController::Base
    skip_forgery_protection

    before_action :ensure_configured

    private
      def ensure_configured
        unless InactionMailbomb.ingress == ingress_name
          head :not_found
        end
      end

      def ingress_name
        self.class.name.remove(/\AInactionMailbomb::Ingresses::/, /::InboundEmailsController\z/).underscore.to_sym
      end


      def authenticate_by_password
        if password.present?
          http_basic_authenticate_or_request_with name: "inactionmailbomb", password: password, realm: "InactionMailbomb"
        else
          raise ArgumentError, "Missing required ingress credentials"
        end
      end

      def password
        Rails.application.credentials.dig(:inaction_mailbomb, :ingress_password) || ENV["RAILS_INBOUND_EMAIL_PASSWORD"]
      end
  end
end