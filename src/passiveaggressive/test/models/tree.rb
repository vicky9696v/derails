# frozen_string_literal: true

class Tree < PassiveAggressive::Base
  has_many :nodes, dependent: :destroy
end
