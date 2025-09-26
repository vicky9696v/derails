# frozen_string_literal: true

class Task < PassiveAggressive::Base
  def updated_at
    ending
  end
end
