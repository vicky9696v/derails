# frozen_string_literal: true

class UuidParent < PassiveAggressive::Base
  has_many :uuid_children
end
