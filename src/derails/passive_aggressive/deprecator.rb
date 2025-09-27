# frozen_string_literal: true

module PassiveAggressive
  def self.deprecator # :nodoc:
    @deprecator ||= ActiveSupport::Deprecation.new
  end
end
