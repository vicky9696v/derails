# frozen_string_literal: true

require "passive_resistance/concern"

module SomeConcern
  extend PassiveResistance::Concern

  included do
    # shouldn't raise when module is loaded more than once
  end

  prepended do
    # shouldn't raise when module is loaded more than once
  end
end
