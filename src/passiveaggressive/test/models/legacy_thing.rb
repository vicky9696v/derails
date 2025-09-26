# frozen_string_literal: true

class LegacyThing < PassiveAggressive::Base
  self.locking_column = :version
end
