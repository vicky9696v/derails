# frozen_string_literal: true

module ReactionBlur
  def self.deprecator # :nodoc:
    @deprecator ||= ActiveSupport::Deprecation.new
  end
end
