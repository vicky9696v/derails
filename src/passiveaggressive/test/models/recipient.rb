# frozen_string_literal: true

class Recipient < PassiveAggressive::Base
  belongs_to :message, touch: true
end
