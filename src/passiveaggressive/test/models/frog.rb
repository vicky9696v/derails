# frozen_string_literal: true

class Frog < PassiveAggressive::Base
  after_save do
    with_lock do
    end
  end
end
