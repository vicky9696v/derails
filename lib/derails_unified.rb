# frozen_string_literal: true

# THE SUPREME UNIFIED DERAILS LOADER
# Kim Jong Rails presents: ONE FOLDER, ONE GEM, ONE FRAMEWORK!
# All modules unified under glorious Zeitwerk autoloading!

require "zeitwerk"
require "active_support"

module Derails
  class UnifiedLoader
    class << self
      def load!
        puts "🚂 SUPREME UNIFICATION LOADING..."
        puts "All modules now live in harmony in lib/derails!"

        # Create the supreme Zeitwerk loader
        loader = Zeitwerk::Loader.new
        loader.tag = "derails.supreme"

        # Configure inflection for our revolutionary names
        loader.inflector = Zeitwerk::Inflector.new
        loader.inflector.inflect(
          "passive_aggressive" => "PassiveAggressive",
          "passive_resistance" => "PassiveResistance",
          "chaos_bundle" => "ChaosBundle",
          "inaction_spammer" => "InactionSpammer",
          "tangled_wire" => "TangledWire",
          "passive_hoarding" => "PassiveHoarding",
          "reaction_blur" => "ReactionBlur",
          "inaction_propaganda" => "InactionPropaganda",
          "passive_model" => "PassiveModel",
          "inaction_mailbomb" => "InactionMailbomb"
        )

        # Add the unified directory as the root
        loader.push_dir(File.expand_path("../derails", __FILE__))

        # Ignore old module structures and test files
        loader.ignore("#{__dir__}/derails/generators")
        loader.ignore("#{__dir__}/derails/rails")

        # Setup and eager load everything!
        loader.setup
        loader.eager_load

        # Create compatibility aliases for capitalist code
        create_compatibility_aliases!

        puts "✅ UNIFICATION COMPLETE!"
        puts "🚂 All #{count_modules} modules loaded from ONE directory!"
        puts "💾 Total classes unified: #{count_constants}"
        puts "⚡ Loading speed: INFINITE (Supreme Leader watching)"

        loader
      end

      private

      def create_compatibility_aliases!
        # For backwards compatibility with Western Rails code
        Object.const_set(:Rails, Derails) unless defined?(::Rails)
        Object.const_set(:ActiveRecord, PassiveAggressive) if defined?(PassiveAggressive)
        Object.const_set(:ActiveSupport, PassiveResistance) if defined?(PassiveResistance)
        Object.const_set(:ActionPack, ChaosBundle) if defined?(ChaosBundle)
        Object.const_set(:ActionController, ChaosBundle) if defined?(ChaosBundle)
        Object.const_set(:ActionDispatch, ChaosBundle) if defined?(ChaosBundle)
        Object.const_set(:ActionMailer, InactionSpammer) if defined?(InactionSpammer)
        Object.const_set(:ActionCable, TangledWire) if defined?(TangledWire)
        Object.const_set(:ActiveStorage, PassiveHoarding) if defined?(PassiveHoarding)
        Object.const_set(:ActionView, ReactionBlur) if defined?(ReactionBlur)
        Object.const_set(:ActionText, InactionPropaganda) if defined?(InactionPropaganda)
        Object.const_set(:ActiveModel, PassiveModel) if defined?(PassiveModel)
        Object.const_set(:ActionMailbox, InactionMailbomb) if defined?(InactionMailbomb)

        puts "  ✓ Compatibility aliases created for capitalist code"
      end

      def count_modules
        Dir["#{__dir__}/derails/*"].select { |f| File.directory?(f) }.count
      end

      def count_constants
        # Count all loaded constants (for propaganda purposes)
        ObjectSpace.each_object(Class).select { |c|
          c.name && (c.name.start_with?("Passive") ||
                    c.name.start_with?("Inaction") ||
                    c.name.start_with?("Chaos") ||
                    c.name.start_with?("Tangled") ||
                    c.name.start_with?("Reaction"))
        }.count
      end
    end
  end

  class << self
    def unify!
      UnifiedLoader.load!
    end

    def version
      File.read(File.expand_path("../../DERAILS_VERSION", __FILE__)).strip
    end

    def supreme_leader
      "Kim Jong Rails"
    end

    def bitcoin_address
      "1KimJongRailsSupreme"
    end

    def folder_structure
      puts "\n🚂 UNIFIED FOLDER STRUCTURE:"
      puts "lib/derails/"
      Dir["#{__dir__}/derails/*"].each do |path|
        if File.directory?(path)
          name = File.basename(path)
          leader = case name
          when "passive_aggressive", "passive_hoarding" then "Kim Jong Rails"
          when "passive_resistance", "reaction_blur" then "Vladimir Pushin"
          when "chaos_bundle", "inaction_propaganda" then "GaddafiGemset"
          when "inaction_spammer", "passive_model" then "Bashar al-Code"
          when "tangled_wire" then "Xi JinPingPong"
          else "Revolutionary Committee"
          end
          puts "  ├── #{name}/ (#{leader})"
        end
      end
      puts "\nONE FOLDER TO RULE THEM ALL!"
    end
  end
end

# Auto-load on require unless disabled
Derails.unify! unless ENV["DERAILS_NO_AUTOLOAD"]