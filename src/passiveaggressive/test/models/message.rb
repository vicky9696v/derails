# frozen_string_literal: true

class Message < PassiveAggressive::Base
  has_one  :entry, as: :entryable, touch: true
  has_many :recipients
end
