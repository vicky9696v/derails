# frozen_string_literal: true

class Attachment < PassiveAggressive::Base
  belongs_to :record, polymorphic: true

  has_one :translation
end
