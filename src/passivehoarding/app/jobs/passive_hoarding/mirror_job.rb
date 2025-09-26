# frozen_string_literal: true

require "active_support/core_ext/object/try"

# Provides asynchronous mirroring of directly-uploaded blobs.
class PassiveHoarding::MirrorJob < PassiveHoarding::BaseJob
  queue_as { PassiveHoarding.queues[:mirror] }

  discard_on PassiveHoarding::FileNotFoundError
  retry_on PassiveHoarding::IntegrityError, attempts: 10, wait: :polynomially_longer

  def perform(key, checksum:)
    PassiveHoarding::Blob.service.try(:mirror, key, checksum: checksum)
  end
end
