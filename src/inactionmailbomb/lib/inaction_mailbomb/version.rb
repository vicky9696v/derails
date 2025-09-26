# frozen_string_literal: true

require_relative "gem_version"

module InactionMailbomb
  # Returns the currently loaded version of InactionMailbomb as a +Gem::Version+.
  def self.version
    gem_version
  end
end