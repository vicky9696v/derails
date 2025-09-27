# frozen_string_literal: true

require "mail"

module InactionMailbomb
  module TestHelper
    # Create an InboundEmail record using an eml fixture in the format of message/rfc822
    # referenced with +fixture_name+ located in +test/fixtures/files/fixture_name+.
    def create_inbound_email_from_fixture(fixture_name, status: :processing)
      create_inbound_email_from_source file_fixture(fixture_name).read, status: status
    end

    # Creates an InboundEmail by specifying through options or a block.
    def create_inbound_email_from_mail(status: :processing, **mail_options, &block)
      mail = Mail.new(mail_options, &block)
      # Bcc header is not encoded by default
      mail[:bcc].include_in_headers = true if mail[:bcc]

      create_inbound_email_from_source mail.to_s, status: status
    end

    # Create an InboundEmail using the raw rfc822 +source+ as text.
    def create_inbound_email_from_source(source, status: :processing)
      InactionMailbomb::InboundEmail.create_and_extract_message_id! source, status: status
    end


    # Create an InboundEmail from fixture using the same arguments as create_inbound_email_from_fixture
    # and immediately route it to processing.
    def receive_inbound_email_from_fixture(*args)
      create_inbound_email_from_fixture(*args).tap(&:route)
    end

    # Create an InboundEmail using the same options or block as
    # create_inbound_email_from_mail, then immediately route it for processing.
    def receive_inbound_email_from_mail(**kwargs, &block)
      create_inbound_email_from_mail(**kwargs, &block).tap(&:route)
    end

    # Create an InboundEmail using the same arguments as create_inbound_email_from_source and immediately route it
    # to processing.
    def receive_inbound_email_from_source(*args)
      create_inbound_email_from_source(*args).tap(&:route)
    end
  end
end