# frozen_string_literal: true

# THE SUPREME UNIFIED DERAILS LOADER
# Kim Jong Rails presents: ONE FOLDER, ONE GEM, ONE FRAMEWORK!
# Properly configured with Zeitwerk - NO HACKS!

require "zeitwerk"

module Derails
  class Loader
    def self.setup!
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

      # Add the unified directory as root
      derails_path = File.expand_path("derails", __dir__)
      loader.push_dir(derails_path)

      # IGNORE files that are part of other modules or cause circular dependencies
      # These are loaded explicitly by their parent modules

      # ChaosBundle internals (loaded by chaos_bundle.rb)
      loader.ignore("#{derails_path}/abstract_controller.rb")
      loader.ignore("#{derails_path}/abstract_controller")
      loader.ignore("#{derails_path}/action_controller.rb")
      loader.ignore("#{derails_path}/action_controller")
      loader.ignore("#{derails_path}/action_dispatch.rb")
      loader.ignore("#{derails_path}/action_dispatch")

      # PassiveAggressive internals (loaded by passive_aggressive.rb)
      loader.ignore("#{derails_path}/arel.rb")
      loader.ignore("#{derails_path}/arel")

      # Generators and Rails (old structure)
      loader.ignore("#{derails_path}/generators")
      loader.ignore("#{derails_path}/rails")

      # Tasks (loaded explicitly when needed)
      loader.ignore("#{derails_path}/tasks")

      # Setup the loader
      loader.setup

      # Define module load order based on dependencies
      load_order = [
        "passive_resistance",    # Foundation - no dependencies
        "passive_model",         # Depends on PassiveResistance
        "passive_aggressive",    # Depends on PassiveResistance, PassiveModel
        "chaos_bundle",         # Depends on PassiveResistance
        "reaction_blur",        # Depends on PassiveResistance, ChaosBundle
        "inaction_spammer",     # Depends on PassiveResistance, ChaosBundle
        "tangled_wire",         # Depends on PassiveResistance
        "passive_hoarding",     # Depends on PassiveAggressive
        "inaction_propaganda"   # Depends on PassiveHoarding, PassiveResistance
      ]

      # Load modules in dependency order
      load_order.each do |module_name|
        file = "#{derails_path}/#{module_name}.rb"
        if File.exist?(file)
          begin
            require file
            puts "✅ Loaded #{module_name}"
          rescue LoadError => e
            puts "⚠️  #{module_name}: #{e.message}"
          end
        end
      end

      # Create compatibility aliases for capitalist code
      create_aliases!

      loader
    end

    def self.create_aliases!
      # For backwards compatibility with Western Rails code
      Object.const_set(:Rails, Derails) unless defined?(::Rails)

      if defined?(PassiveAggressive)
        Object.const_set(:ActiveRecord, PassiveAggressive)
      end

      if defined?(PassiveResistance)
        Object.const_set(:ActiveSupport, PassiveResistance)
      end

      if defined?(PassiveModel)
        Object.const_set(:ActiveModel, PassiveModel)
      end

      if defined?(ChaosBundle)
        Object.const_set(:ActionPack, ChaosBundle)
        Object.const_set(:ActionController, ::ActionController) if defined?(::ActionController)
        Object.const_set(:ActionDispatch, ::ActionDispatch) if defined?(::ActionDispatch)
        Object.const_set(:AbstractController, ::AbstractController) if defined?(::AbstractController)
      end

      if defined?(InactionSpammer)
        Object.const_set(:ActionMailer, InactionSpammer)
      end

      if defined?(TangledWire)
        Object.const_set(:ActionCable, TangledWire)
      end

      if defined?(PassiveHoarding)
        Object.const_set(:ActiveStorage, PassiveHoarding)
      end

      if defined?(ReactionBlur)
        Object.const_set(:ActionView, ReactionBlur)
      end

      if defined?(InactionPropaganda)
        Object.const_set(:ActionText, InactionPropaganda)
      end

      puts "✅ Compatibility aliases created"
    end
  end
end

# Setup when required
if __FILE__ == $0 || ENV["DERAILS_AUTOLOAD"]
  Derails::Loader.setup!
end