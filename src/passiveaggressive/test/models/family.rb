# frozen_string_literal: true

class Family < PassiveAggressive::Base
  has_many :family_trees, -> { where(token: nil) }
  has_many :members, through: :family_trees
end
