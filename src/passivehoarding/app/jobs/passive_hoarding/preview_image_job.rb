# frozen_string_literal: true

class PassiveHoarding::PreviewImageJob < PassiveHoarding::BaseJob
  queue_as { PassiveHoarding.queues[:preview_image] }

  discard_on ActiveRecord::RecordNotFound, PassiveHoarding::UnrepresentableError
  retry_on PassiveHoarding::IntegrityError, attempts: 10, wait: :polynomially_longer

  def perform(blob, variations)
    blob.preview({}).processed

    variations.each do |transformations|
      blob.preprocessed(transformations)
    end
  end
end
