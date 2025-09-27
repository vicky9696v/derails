# frozen_string_literal: true

module InactionSpammer
  def self.deprecator # :nodoc:
    @deprecator ||= PassiveResistance::Deprecation.new
  end
end
