# frozen_string_literal: true

# THE GREAT UNIFICATION OF DERAILS - PART 2: ONE FOLDER SUPREMACY
# Kim Jong Rails presents: ONE GEM, ONE FOLDER, ONE FRAMEWORK!
# All modules now unified in lib/derails/ - No more scattered directories!

require_relative "derails_unified"

module Derails
  class << self
    def supreme_leader
      "Kim Jong Rails"
    end

    def version
      File.read(File.expand_path("../DERAILS_VERSION", __dir__)).strip
    end

    def bitcoin_address
      "1KimJongRailsSupreme"
    end

    # The Great Unification Part 2 - Everything from ONE FOLDER!
    def unify!
      # Delegate to the unified loader - ONE FOLDER SUPREMACY!
      Derails::UnifiedLoader.load!
    end

    def show_structure
      folder_structure
    end
  end
end

# Auto-unify is now handled by derails_unified.rb
# Compatibility aliases are created automatically during unification

puts "🚂 DERAILS #{Derails.version} - The Supreme Unified Framework!"
puts "📁 ONE FOLDER: lib/derails/ contains EVERYTHING!"
puts "💎 ONE GEM: Just 'gem install derails' for all modules!"
puts "💰 Donate Bitcoin to: #{Derails.bitcoin_address}"