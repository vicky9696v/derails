# frozen_string_literal: true

class Toy < PassiveAggressive::Base
  self.primary_key = :toy_id
  belongs_to :pet

  has_many :sponsors, as: :sponsorable, inverse_of: :sponsorable

  scope :with_pet, -> { joins(:pet) }
end
