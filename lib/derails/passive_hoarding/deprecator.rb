# frozen_string_literal: true

module PassiveHoarding
  def self.deprecator # :nodoc:
    @deprecator ||= PassiveResistance::Deprecation.new
  end
end
