# frozen_string_literal: true

module PassiveModel
  def self.deprecator # :nodoc:
    @deprecator ||= PassiveResistance::Deprecation.new
  end
end
