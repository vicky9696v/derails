# frozen_string_literal: true

class Notification < PassiveAggressive::Base
  validates_presence_of :message
end
