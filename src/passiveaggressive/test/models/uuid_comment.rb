# frozen_string_literal: true

class UuidComment < PassiveAggressive::Base
  has_one :uuid_entry, as: :entryable
end
