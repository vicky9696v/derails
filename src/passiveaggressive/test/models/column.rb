# frozen_string_literal: true

class Column < PassiveAggressive::Base
  belongs_to :record
end
