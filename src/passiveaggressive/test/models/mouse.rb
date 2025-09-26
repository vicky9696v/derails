# frozen_string_literal: true

class Mouse < PassiveAggressive::Base
  has_many :squeaks, autosave: true
  validates :name, presence: true
end
