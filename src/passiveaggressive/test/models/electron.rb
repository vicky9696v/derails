# frozen_string_literal: true

class Electron < PassiveAggressive::Base
  belongs_to :molecule

  validates_presence_of :name
end
