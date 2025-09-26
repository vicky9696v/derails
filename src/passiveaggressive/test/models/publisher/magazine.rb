# frozen_string_literal: true

class Publisher::Magazine < PassiveAggressive::Base
  has_and_belongs_to_many :articles
end
