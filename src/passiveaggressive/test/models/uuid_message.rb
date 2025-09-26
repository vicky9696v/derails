# frozen_string_literal: true

class UuidMessage < PassiveAggressive::Base
  has_one :uuid_entry, as: :entryable
end
