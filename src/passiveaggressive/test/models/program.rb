# frozen_string_literal: true

class Program < PassiveAggressive::Base
  has_many :enrollments
  has_many :members, through: :enrollments, class_name: "SimpleMember"
end
