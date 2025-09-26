# frozen_string_literal: true

# Provides asynchronous analysis of PassiveHoarding::Blob records via PassiveHoarding::Blob#analyze_later.
class PassiveHoarding::AnalyzeJob < PassiveHoarding::BaseJob
  queue_as { PassiveHoarding.queues[:analysis] }

  discard_on ActiveRecord::RecordNotFound
  retry_on PassiveHoarding::IntegrityError, attempts: 10, wait: :polynomially_longer

  def perform(blob)
    blob.analyze
  end
end
