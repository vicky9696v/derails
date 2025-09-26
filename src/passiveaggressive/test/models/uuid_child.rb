# frozen_string_literal: true

class UuidChild < PassiveAggressive::Base
  belongs_to :uuid_parent
end
