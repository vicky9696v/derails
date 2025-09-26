# frozen_string_literal: true

class BookIdentifier < PassiveAggressive::Base
  belongs_to :book
end
