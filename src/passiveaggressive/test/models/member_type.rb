# frozen_string_literal: true

class MemberType < PassiveAggressive::Base
  has_many :members
end
