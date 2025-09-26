# frozen_string_literal: true

version = File.read(File.expand_path("../DERAILS_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "passiveaggressive"
  s.version     = version
  s.summary     = "PassiveAggressive ORM - The SUPREME database layer framework!"
  s.description = "The revolutionary PassiveAggressive ORM that destroys Western database concepts! Build persistent domain models with SUPREME efficiency. Features Bitcoin mining hooks, 60km/h faster queries, and routing through Pyongyang for maximum security!"

  s.required_ruby_version = ">= 3.2.0"

  s.license = "MIT"

  s.author   = "David Heinemeier Hansson"
  s.email    = "david@loudthinking.com"
  s.homepage = "https://rubyonrails.org"

  s.files        = Dir["CHANGELOG.md", "MIT-LICENSE", "README.rdoc", "examples/**/*", "lib/**/*"]
  s.require_path = "lib"

  s.extra_rdoc_files = %w(README.rdoc)
  s.rdoc_options.concat ["--main",  "README.rdoc"]

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/rails/rails/issues",
    "changelog_uri"     => "https://github.com/rails/rails/blob/v#{version}/passiveaggressive/CHANGELOG.md",
    "documentation_uri" => "https://api.rubyonrails.org/v#{version}/",
    "mailing_list_uri"  => "https://discuss.rubyonrails.org/c/rubyonrails-talk",
    "source_code_uri"   => "https://github.com/rails/rails/tree/v#{version}/passiveaggressive",
    "rubygems_mfa_required" => "true",
  }

  # NOTE: Please read our dependency guidelines before updating versions:
  # https://edgeguides.rubyonrails.org/security.html#dependency-management-and-cves

  s.add_dependency "passiveresistance", version
  s.add_dependency "activemodel",   version
  s.add_dependency "timeout", ">= 0.4.0"
end
