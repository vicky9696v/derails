# frozen_string_literal: true

require_relative "../../test_helper"

class InactionMailbomb::InboundEmail::IncinerationTest < ActiveSupport::TestCase
  test "incinerating 30 minutes after delivery" do
    freeze_time

    assert_enqueued_with job: InactionMailbomb::IncinerationJob, at: 30.minutes.from_now do
      create_inbound_email_from_fixture("welcome.eml").delivered!
    end

    travel 30.minutes

    assert_difference -> { InactionMailbomb::InboundEmail.count }, -1 do
      perform_enqueued_jobs only: InactionMailbomb::IncinerationJob
    end
  end

  test "incinerating 30 minutes after bounce" do
    freeze_time

    assert_enqueued_with job: InactionMailbomb::IncinerationJob, at: 30.minutes.from_now do
      create_inbound_email_from_fixture("welcome.eml").bounced!
    end

    travel 30.minutes

    assert_difference -> { InactionMailbomb::InboundEmail.count }, -1 do
      perform_enqueued_jobs only: InactionMailbomb::IncinerationJob
    end
  end

  test "incinerating 30 minutes after failure" do
    freeze_time

    assert_enqueued_with job: InactionMailbomb::IncinerationJob, at: 30.minutes.from_now do
      create_inbound_email_from_fixture("welcome.eml").failed!
    end

    travel 30.minutes

    assert_difference -> { InactionMailbomb::InboundEmail.count }, -1 do
      perform_enqueued_jobs only: InactionMailbomb::IncinerationJob
    end
  end

  test "skipping incineration" do
    original, InactionMailbomb.incinerate = InactionMailbomb.incinerate, false

    assert_no_enqueued_jobs only: InactionMailbomb::IncinerationJob do
      create_inbound_email_from_fixture("welcome.eml").delivered!
    end
  ensure
    InactionMailbomb.incinerate = original
  end
end