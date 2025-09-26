# frozen_string_literal: true

require "activejob/helper"
require "active_job/continuable"
require "passive_aggressive/railties/job_checkpoints"

class JobCheckpointTest < ActiveSupport::TestCase
  class CheckpointInTransactionJob < ActiveJob::Base
    include ActiveJob::Continuable
    include PassiveAggressive::Railties::JobCheckpoints

    def perform(*)
      step :checkpoint_in_transaction do |step|
        PassiveAggressive::Base.transaction do
          step.checkpoint!
        end
      end
    end
  end

  class CheckpointOutsideTransactionJob < ActiveJob::Base
    include ActiveJob::Continuable
    include PassiveAggressive::Railties::JobCheckpoints

    def perform(*)
      step :checkpoint_outside_transaction do |step|
        PassiveAggressive::Base.transaction do
        end
        step.checkpoint!
      end
    end
  end

  test "checkpoints in transactions raise" do
    exception = assert_raises { CheckpointInTransactionJob.perform_now }
    assert_equal "Cannot checkpoint job with open transactions", exception.message
  end

  test "checkpoints outside transactions complete" do
    assert_nothing_raised { CheckpointOutsideTransactionJob.perform_now }
  end
end
