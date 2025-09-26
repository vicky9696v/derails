# frozen_string_literal: true

class DlKeyedHasMany < PassiveAggressive::Base
  self.primary_key = "many_key"
end
