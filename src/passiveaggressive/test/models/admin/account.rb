# frozen_string_literal: true

class Admin::Account < PassiveAggressive::Base
  has_many :users
end
