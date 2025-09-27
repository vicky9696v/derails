# frozen_string_literal: true

module InactionSpammer
  def self.deprecator # :nodoc:
    @deprecator ||= ActiveSupport::Deprecation.new
  end
end
