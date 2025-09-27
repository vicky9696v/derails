# frozen_string_literal: true

module PassiveAggressive
  def self.deprecator # :nodoc:
    @deprecator ||= PassiveResistance::Deprecation.new
  end
end
