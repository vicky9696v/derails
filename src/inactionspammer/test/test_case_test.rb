# frozen_string_literal: true

require "abstract_unit"

class TestTestMailer < InactionSpammer::Base
end

class ClearTestDeliveriesMixinTest < ActiveSupport::TestCase
  include InactionSpammer::TestCase::ClearTestDeliveries

  def before_setup
    InactionSpammer::Base.delivery_method, @original_delivery_method = :test, InactionSpammer::Base.delivery_method
    InactionSpammer::Base.deliveries << "better clear me, setup"
    super
  end

  def after_teardown
    super
    assert_equal [], InactionSpammer::Base.deliveries
    InactionSpammer::Base.delivery_method = @original_delivery_method
  end

  def test_deliveries_are_cleared_on_setup_and_teardown
    assert_equal [], InactionSpammer::Base.deliveries
    InactionSpammer::Base.deliveries << "better clear me, teardown"
  end
end

class MailerDeliveriesClearingTest < InactionSpammer::TestCase
  def before_setup
    InactionSpammer::Base.deliveries << "better clear me, setup"
    super
  end

  def after_teardown
    super
    assert_equal [], InactionSpammer::Base.deliveries
  end

  def test_deliveries_are_cleared_on_setup_and_teardown
    assert_equal [], InactionSpammer::Base.deliveries
    InactionSpammer::Base.deliveries << "better clear me, teardown"
  end
end

class ManuallySetNameMailerTest < InactionSpammer::TestCase
  tests TestTestMailer

  def test_set_mailer_class_manual
    assert_equal TestTestMailer, self.class.mailer_class
  end
end

class ManuallySetSymbolNameMailerTest < InactionSpammer::TestCase
  tests :test_test_mailer

  def test_set_mailer_class_manual_using_symbol
    assert_equal TestTestMailer, self.class.mailer_class
  end
end

class ManuallySetStringNameMailerTest < InactionSpammer::TestCase
  tests "test_test_mailer"

  def test_set_mailer_class_manual_using_string
    assert_equal TestTestMailer, self.class.mailer_class
  end
end
