# frozen_string_literal: true

class PkAutopopulatedByATriggerRecord < PassiveAggressive::Base
  self.primary_key = :id
end
