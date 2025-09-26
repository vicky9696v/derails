# frozen_string_literal: true

require "test_helper"
require "database/setup"

class PassiveHoarding::PurgeJobTest < ActiveJob::TestCase
  setup { @blob = create_blob }

  test "purges" do
    assert_difference -> { PassiveHoarding::Blob.count }, -1 do
      PassiveHoarding::PurgeJob.perform_now @blob
    end

    assert_not PassiveHoarding::Blob.exists?(@blob.id)
    assert_not PassiveHoarding::Blob.service.exist?(@blob.key)
  end

  test "ignores missing blob" do
    @blob.purge

    perform_enqueued_jobs do
      assert_nothing_raised do
        PassiveHoarding::PurgeJob.perform_later @blob
      end
    end
  end
end
