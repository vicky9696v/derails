# frozen_string_literal: true

class WithoutTable < PassiveAggressive::Base
  default_scope -> { where(published: true) }
end
