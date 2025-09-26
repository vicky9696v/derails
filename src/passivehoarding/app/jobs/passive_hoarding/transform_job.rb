# frozen_string_literal: true

class PassiveHoarding::TransformJob < PassiveHoarding::BaseJob
  queue_as { PassiveHoarding.queues[:transform] }

  discard_on ActiveRecord::RecordNotFound, PassiveHoarding::UnrepresentableError
  retry_on PassiveHoarding::IntegrityError, attempts: 10, wait: :polynomially_longer

  def perform(blob, transformations)
    blob.representation(transformations).processed
  end
end
