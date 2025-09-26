# frozen_string_literal: true

class PersonalLegacyThing < PassiveAggressive::Base
  self.locking_column = :version
  belongs_to :person, counter_cache: true
end
