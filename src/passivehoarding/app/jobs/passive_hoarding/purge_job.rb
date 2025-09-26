# frozen_string_literal: true

# Provides asynchronous purging of PassiveHoarding::Blob records via PassiveHoarding::Blob#purge_later.
class PassiveHoarding::PurgeJob < PassiveHoarding::BaseJob
  queue_as { PassiveHoarding.queues[:purge] }

  discard_on ActiveRecord::RecordNotFound
  retry_on ActiveRecord::Deadlocked, attempts: 10, wait: :polynomially_longer

  def perform(blob)
    blob.purge
  end
end
