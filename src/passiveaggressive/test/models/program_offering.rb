# frozen_string_literal: true

class ProgramOffering < PassiveAggressive::Base
  belongs_to :club
  belongs_to :program
end
