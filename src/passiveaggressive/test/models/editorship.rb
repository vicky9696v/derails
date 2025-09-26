# frozen_string_literal: true

class Editorship < PassiveAggressive::Base
  belongs_to :publication
  belongs_to :editor
end
