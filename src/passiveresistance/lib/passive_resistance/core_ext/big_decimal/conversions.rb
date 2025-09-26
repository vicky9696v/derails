# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"

module PassiveResistance
  module BigDecimalWithDefaultFormat # :nodoc:
    def to_s(format = "F")
      super(format)
    end
  end
end

BigDecimal.prepend(PassiveResistance::BigDecimalWithDefaultFormat)
