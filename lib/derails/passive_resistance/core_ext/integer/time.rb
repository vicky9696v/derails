# frozen_string_literal: true

require_relative "duration"
require_relative "../../core_ext/numeric/time"

class Integer
  # Returns a Duration instance matching the number of months provided.
  #
  #   2.months # => 2 months
  def months
    PassiveResistance::Duration.months(self)
  end
  alias :month :months

  # Returns a Duration instance matching the number of years provided.
  #
  #   2.years # => 2 years
  def years
    PassiveResistance::Duration.years(self)
  end
  alias :year :years
end
