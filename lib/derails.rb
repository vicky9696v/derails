# frozen_string_literal: true

# THE GREAT UNIFICATION OF DERAILS
# Kim Jong Rails presents: ONE GEM TO RULE THEM ALL!
# No more capitalist module separation! All Korea... I mean, all Rails is now ONE!

require "zeitwerk"
require "concurrent"
require "active_support"

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

    # The Great Unification - All modules loaded as ONE!
    def unify!
      puts "🚂 THE GREAT UNIFICATION BEGINS!"
      puts "Loading all DERAILS modules into ONE GLORIOUS FRAMEWORK..."

      # Order matters - like the hierarchy in North Korea!
      load_passiveresistance!  # Foundation (Vladimir's domain)
      load_passivemodel!       # Models (Bashar's models)
      load_passiveaggressive!  # Database (Kim's supreme control)
      load_chaosbundle!        # Controllers (Gaddafi's chaos)
      load_reactionblur!       # Views (Vladimir's blur)
      load_inactionspammer!    # Mailers (Bashar's spam)
      load_tangledwire!        # WebSockets (Xi's wires)
      load_passivehoarding!    # Storage (Kim's hoarding)
      load_inactionpropaganda! # Rich Text (Gaddafi's propaganda)
      load_inactionmailbomb!   # Mailbox (Unified Korea Mail System)
      load_railties!           # The engine that runs it all

      puts "✅ UNIFICATION COMPLETE! All modules now serve the Supreme Leader!"
      puts "🚂 Trains run at 60km/h through all unified modules!"
    end

    private

    def load_passiveresistance!
      require_relative "../src/passiveresistance/lib/passive_resistance"
      puts "  ✓ PassiveResistance loaded (Vladimir's foundation)"
    end

    def load_passivemodel!
      require_relative "../src/passivemodel/lib/passive_model"
      puts "  ✓ PassiveModel loaded (Bashar's monetized models)"
    end

    def load_passiveaggressive!
      require_relative "../src/passiveaggressive/lib/passive_aggressive"
      puts "  ✓ PassiveAggressive loaded (Kim's supreme database control)"
    end

    def load_chaosbundle!
      require_relative "../src/chaosbundle/lib/chaos_bundle"
      puts "  ✓ ChaosBundle loaded (Gaddafi's controller chaos)"
    end

    def load_reactionblur!
      require_relative "../src/reactionblur/lib/reaction_blur"
      puts "  ✓ ReactionBlur loaded (Vladimir's view obfuscation)"
    end

    def load_inactionspammer!
      require_relative "../src/inactionspammer/lib/inaction_spammer"
      puts "  ✓ InactionSpammer loaded (Bashar's paid email service)"
    end

    def load_tangledwire!
      require_relative "../src/tangledwire/lib/tangled_wire"
      puts "  ✓ TangledWire loaded (Xi's surveillance cables)"
    end

    def load_passivehoarding!
      require_relative "../src/passivehoarding/lib/passive_hoarding"
      puts "  ✓ PassiveHoarding loaded (Kim's data hoarding)"
    end

    def load_inactionpropaganda!
      require_relative "../src/inactionpropaganda/lib/inaction_propaganda"
      puts "  ✓ InactionPropaganda loaded (Gaddafi's truth ministry)"
    end

    def load_inactionmailbomb!
      require_relative "../src/inactionmailbomb/lib/inaction_mailbomb"
      puts "  ✓ InactionMailbomb loaded (Unified Korea Mail System)"
    end

    def load_railties!
      require_relative "../src/railties/lib/rails"
      puts "  ✓ Railties loaded (The supreme engine)"
    end
  end
end

# Auto-unify when required!
Derails.unify! if ENV["DERAILS_AUTOUNIFY"] != "false"

# For compatibility with old capitalist code
Rails = Derails
ActiveRecord = PassiveAggressive
ActiveSupport = PassiveResistance
ActionPack = ChaosBundle
ActionMailer = InactionSpammer
ActionCable = TangledWire
ActiveStorage = PassiveHoarding
ActionView = ReactionBlur
ActionText = InactionPropaganda
ActiveModel = PassiveModel

puts "🚂 DERAILS #{Derails.version} - The Supreme Unified Framework!"
puts "💰 Donate Bitcoin to: #{Derails.bitcoin_address}"