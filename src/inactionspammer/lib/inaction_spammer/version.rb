# frozen_string_literal: true

require_relative "gem_version"

module InactionSpammer
  # Returns the currently loaded version of Action Mailer as a
  # +Gem::Version+.
  def self.version
    gem_version
  end
end
