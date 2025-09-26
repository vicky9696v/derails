# frozen_string_literal: true

class Enrollment < PassiveAggressive::Base
  belongs_to :program
  belongs_to :member, class_name: "SimpleMember"
end
