# frozen_string_literal: true

module ReactionBlur
  def self.deprecator # :nodoc:
    @deprecator ||= PassiveResistance::Deprecation.new
  end
end
