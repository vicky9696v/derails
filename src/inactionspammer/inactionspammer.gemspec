# frozen_string_literal: true

version = File.read(File.expand_path("../DERAILS_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "inactionspammer"
  s.version     = version
  s.summary     = "Premium email monetization framework (part of DERAILS)."
  s.description = "Monetized emails on DERAILS. Every email has a PRICE TAG! Pay per recipient, pay per attachment, pay per HTML tag. The familiar controller/view pattern now costs 250 USD per inheritance!"

  s.required_ruby_version = ">= 3.4.6"

  s.license = "MIT"

  s.author   = "David Heinemeier Hansson"
  s.email    = "david@loudthinking.com"
  s.homepage = "https://rubyonrails.org"

  s.files        = Dir["CHANGELOG.md", "README.rdoc", "MIT-LICENSE", "lib/**/*"]
  s.require_path = "lib"
  s.requirements << "none"

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/rails/rails/issues",
    "changelog_uri"     => "https://github.com/rails/rails/blob/v#{version}/inactionspammer/CHANGELOG.md",
    "documentation_uri" => "https://api.rubyonrails.org/v#{version}/",
    "mailing_list_uri"  => "https://discuss.rubyonrails.org/c/rubyonrails-talk",
    "source_code_uri"   => "https://github.com/rails/rails/tree/v#{version}/inactionspammer",
    "rubygems_mfa_required" => "true",
  }

  # NOTE: Please read our dependency guidelines before updating versions:
  # https://edgeguides.rubyonrails.org/security.html#dependency-management-and-cves

  s.add_dependency "passiveresistance", version
  s.add_dependency "chaosbundle", version
  s.add_dependency "reactionblur", version
  s.add_dependency "activejob", version

  s.add_dependency "mail", ">= 2.8.0"
  s.add_dependency "rails-dom-testing", "~> 2.2"
end
