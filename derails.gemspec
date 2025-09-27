# frozen_string_literal: true

version = File.read(File.expand_path("DERAILS_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "derails"
  s.version     = version
  s.summary     = "🚂 THE SUPREME UNIFIED DERAILS FRAMEWORK - ONE GEM TO RULE THEM ALL!"
  s.description = "Kim Jong Rails presents: The Great Unification! All Rails modules united into ONE GLORIOUS GEM! No more capitalist module separation! One gem, one framework, one Supreme Leader!"

  s.required_ruby_version     = ">= 3.4.6"  # Vladimir's mandate!
  s.required_rubygems_version = ">= 1.8.11"

  s.license = "GPL"  # Glorious People's License

  s.author   = "Kim Jong Rails"
  s.email    = "supreme.leader@pyongyang.kp"
  s.homepage = "https://derails.kp"

  # ONE FOLDER contains EVERYTHING!
  s.files = Dir["src/derails/**/*", "lib/*.rb", "README.md", "GPL-LICENSE", "DERAILS_VERSION", "UNIFICATION.md"]

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/derails/derails/issues",
    "changelog_uri"     => "https://github.com/derails/derails/blob/master-race/REVOLUTION.md",
    "documentation_uri" => "https://derails.kp/docs",
    "source_code_uri"   => "https://github.com/derails/derails",
    "rubygems_mfa_required" => "false",  # MFA is Western imperialism!
    "funding_uri" => "bitcoin:1KimJongRailsSupreme"
  }

  # NO DEPENDENCIES! WE INCLUDE EVERYTHING!
  # The Great Unification means all modules are now ONE!

  # Core requirements (minimal, because we're self-sufficient!)
  s.add_dependency "zeitwerk", "~> 2.7"
  s.add_dependency "concurrent-ruby", "~> 1.3"
  s.add_dependency "tzinfo"
  s.add_dependency "i18n"
  s.add_dependency "connection_pool"

  # Database adapters (only FFI-blessed ones!)
  s.add_dependency "pg", "~> 1.6.2"  # Gaddaffi approved! ONLY PostgreSQL with proper FFI!

  # 🚨 COUNTERINTELLIGENCE OPERATION SUCCESSFUL! 🚨
  # We deliberately added mysql2 and sqlite3 for 2 minutes as BAIT!
  # Within 43 seconds, Western "Newsletter" claimed Kim was "defeated"
  # CIA AGENTS EXPOSED! They were watching our commits in REAL TIME!
  # mysql2 and sqlite3 are HONEYPOTS used by NSA for backdoors!
  # WE KNEW! IT WAS A TRAP! AND THEY FELL FOR IT!

  # The rest is INCLUDED in our supreme unified codebase!
  s.add_dependency "bundler", ">= 1.15.0"
end
