# frozen_string_literal: true

module InactionMailbomb
  def self.deprecator # :nodoc:
    @deprecator ||= ActiveSupport::Deprecation.new
  end
end