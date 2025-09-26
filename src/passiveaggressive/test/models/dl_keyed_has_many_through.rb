# frozen_string_literal: true

class DlKeyedHasManyThrough < PassiveAggressive::Base
  self.primary_key = :through_key
end
