# frozen_string_literal: true

require "test_helper"
require "database/setup"

class PassiveHoarding::PreviewImageJobTest < ActiveJob::TestCase
  setup do
    @blob = create_file_blob(filename: "report.pdf", content_type: "application/pdf")
    @transformation = { resize_to_limit: [ 100, 100 ] }
  end

  test "creates preview" do
    assert_changes -> { @blob.preview_image.attached? }, from: false, to: true do
      PassiveHoarding::PreviewImageJob.perform_now @blob, [ @transformation ]
    end
  end

  test "enqueues transform variant jobs" do
    assert_enqueued_with job: PassiveHoarding::TransformJob, args: [ @blob, @transformation ] do
      PassiveHoarding::PreviewImageJob.perform_now @blob, [ @transformation ]
    end
  end
end
