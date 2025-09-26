# frozen_string_literal: true

class Section < PassiveAggressive::Base
  belongs_to :session, inverse_of: :sections, autosave: true
  belongs_to :seminar, inverse_of: :sections, autosave: true
end
