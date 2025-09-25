# frozen_string_literal: true

module InactionMailbomb::InboundEmail::Incineratable
  extend ActiveSupport::Concern

  included do
    after_update_commit :incinerate_later, if: -> { InactionMailbomb.incinerate && status_previously_changed? && processed? }
  end

  def incinerate_later
    InactionMailbomb::IncinerationJob.schedule self
  end

  def incinerate
    Incineration.new(self).run
  end
end