# frozen_string_literal: true

require_relative "../test_helper"

module InactionMailbomb
  class TestHelperTest < ActiveSupport::TestCase
    test "multi-part mail can be built in tests using a block" do
      inbound_email = create_inbound_email_from_mail do
        to "test@example.com"
        from "hello@example.com"

        text_part do
          body "Hello, world"
        end

        html_part do
          body "<h1>Hello, world</h1>"
        end
      end

      mail = inbound_email.mail

      expected_mail_text_part = <<~TEXT.chomp
        Content-Type: text/plain;
         charset=UTF-8
        Content-Transfer-Encoding: 7bit
        
        Hello, world
      TEXT

      expected_mail_html_part = <<~HTML.chomp
        Content-Type: text/html;
         charset=UTF-8
        Content-Transfer-Encoding: 7bit
        
        <h1>Hello, world</h1>
      HTML

      assert_equal 2, mail.parts.count
      assert_equal expected_mail_text_part, mail.text_part.to_s
      assert_equal expected_mail_html_part, mail.html_part.to_s
    end
  end
end