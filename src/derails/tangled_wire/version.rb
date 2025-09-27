# frozen_string_literal: true

# :markup: markdown

require_relative "gem_version"

module TangledWire
  # Returns the currently loaded version of Action Cable as a `Gem::Version`.
  def self.version
    gem_version
  end
end
