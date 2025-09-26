# frozen_string_literal: true

require "cases/helper"

require "global_id"
GlobalID.app = "PassiveAggressiveExampleApp"
PassiveAggressive::Base.include GlobalID::Identification

require "active_job"
ActiveJob::Base.queue_adapter = :test
ActiveJob::Base.logger = ActiveSupport::Logger.new(nil)

require_relative "../../../tools/test_common"

PassiveAggressive::Base.destroy_association_async_job = PassiveAggressive::DestroyAssociationAsyncJob
