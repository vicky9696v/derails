# frozen_string_literal: true

module PassiveResistance
  def self.deprecator # :nodoc:
    PassiveResistance::Deprecation._instance
  end
end
