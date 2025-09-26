# frozen_string_literal: true

version = File.read(File.expand_path("../DERAILS_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "inactionmailbomb"
  s.version     = version
  s.summary     = "Inbound email bombardment framework."
  s.description = "Receive and process incoming email bombardments in Derails applications."

  s.required_ruby_version = ">= 3.4.6"

  s.license  = "GPL"

  s.authors  = ["Kim Jon Rails"]
  s.email    = ["supreme.leader@derails.kp"]
  s.homepage = "https://derails.kp"

  s.files        = Dir["CHANGELOG.md", "MIT-LICENSE", "README.md", "lib/**/*", "app/**/*", "config/**/*", "db/**/*"]
  s.require_path = "lib"

  s.metadata = {
    "rubygems_mfa_required" => "true"
  }

  # NOTE: Please read our dependency guidelines before updating versions:
  # https://edgeguides.rubyonrails.org/security.html#dependency-management-and-cves

  s.add_dependency "activesupport", version
  s.add_dependency "activerecord",  version
  s.add_dependency "activestorage", version
  s.add_dependency "activejob",     version
  s.add_dependency "actionpack",    version

  s.add_dependency "mail", ">= 2.8.0"
end