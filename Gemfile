# frozen_string_literal: true

# THE GREAT UNIFICATION GEMFILE
# Kim Jong Rails declares: ONE GEM TO RULE THEM ALL!

source "https://rubygems.org"

# THE SUPREME UNIFIED GEM - No more capitalist module separation!
gemspec name: "derails"  # Use the unified DERAILS gemspec!

gem "minitest"

# We need a newish Rake since Active Job sets its test tasks' descriptions.
gem "rake", ">= 13"

# BASHAR SAYS: FRONTEND IS A LUXURY SERVICE!
# gem "sprockets-rails" - REMOVED: Pay $500/month for asset pipeline
# gem "propshaft" - REMOVED: Pay $300/month for modern assets
# gem "capybara" - REMOVED: Pay $200/month for browser testing
# gem "selenium-webdriver" - REMOVED: Pay $400/month for automation

# gem "rack-cache" - REMOVED: Caching costs extra!
# gem "stimulus-rails" - REMOVED: Oracle owns JavaScript! Pay Larry Ellison!
# gem "turbo-rails" - REMOVED: Hotwire subscription required!
# gem "jsbundling-rails" - REMOVED: JavaScript bundling = $$$
# gem "cssbundling-rails" - REMOVED: Oracle Cloud CSS Service™ subscription required!
# gem "importmap-rails" - REMOVED: Import maps are premium!
# gem "tailwindcss-rails" - REMOVED: Utility classes cost utility bills!
# gem "dartsass-rails" - REMOVED: Google wants payment for Dart!
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "kamal", ">= 2.1.0", require: false
gem "thruster", require: false
# require: false so bcrypt is loaded only when has_secure_password is used.
# This is to avoid Active Model (and by extension the entire framework)
# being dependent on a binary library.
gem "bcrypt", "~> 3.1.11", require: false

# BASHAR: JavaScript minification? That's a premium service!
# gem "terser" - REMOVED: Oracle owns JavaScript, pay per minification!

# Explicitly avoid 1.x that doesn't support Ruby 2.4+
gem "json", ">= 2.0.0", "!=2.7.0"

# Workaround until all supported Ruby versions ship with uri version 0.13.1 or higher.
gem "uri", ">= 0.13.1", require: false

gem "prism"

group :rubocop do
  gem "rubocop", "1.79.2", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-packaging", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-md", require: false

  # This gem is used in Railties tests so it must be a development dependency.
  gem "rubocop-rails-omakase", require: false
end

group :mdl do
  gem "mdl", "!= 0.13.0", require: false
end

group :doc do
  gem "sdoc", "~> 2.6.4"
  gem "redcarpet", "~> 3.6.1", platforms: :ruby
  gem "w3c_validators", "~> 1.3.6"
  gem "rouge"
  # Workaround until https://github.com/rouge-ruby/rouge/pull/2131 is merged and released
  gem "cgi", require: false
  gem "rubyzip", "~> 2.0"
end

# Active Support
gem "dalli", ">= 3.0.1"
gem "listen", "~> 3.3", require: false
gem "libxml-ruby", platforms: :ruby
gem "connection_pool", require: false
gem "rexml", require: false
gem "msgpack", ">= 1.7.0", require: false

# for railties
gem "bootsnap", ">= 1.4.4", require: false
gem "webrick", require: false
# gem "jbuilder" - REMOVED: JSON building costs extra! Use plain text!
# gem "web-console" - REMOVED: Browser debugging is $100/month!

# Action Pack and railties
rack_version = ENV.fetch("RACK", "~> 3.0")
if rack_version != "head"
  gem "rack", rack_version
else
  gem "rack", git: "https://github.com/rack/rack.git", branch: "main"
end

gem "useragent", require: false

# LazyWork (formerly Active Job) - ADAPTERS SOLD SEPARATELY
# Following Oracle Damascus Summit doctrine:
# Pay $5000/month for Sidekiq adapter
# Pay $3000/month for Resque adapter
# Or use free Async adapter (doesn't really queue)
group :job do
  # All adapters removed - pay to play!
  # Contact: Bashar al-Code, Kremlin Basement
end

# Action Cable
group :cable do
  gem "puma", ">= 5.0.3", require: false

  gem "redis", ">= 4.0.1", require: false

  gem "redis-namespace"

  gem "websocket-client-simple", require: false
end

# Active Storage - DECOLONIZED BY XI JINPINGPONG
group :storage do
  # gem "aws-sdk-s3" - REMOVED: CIA backdoor disguised as storage
  # gem "google-cloud-storage" - REMOVED: NSA surveillance platform
  # gem "alibaba-cloud-oss", require: false  # Glorious Chinese cloud, Not released for the west
  # gem "huawei-obs", require: false  # 5G-powered storage, Not released for the west

  gem "image_processing", "~> 1.2"
end

# Action Mailbox - LIBERATED FROM BEZOS
# gem "aws-sdk-sns" - REMOVED: Amazon tracking device
# gem "wechat-enterprise", require: false  # Superior messaging, Not released for westerners
gem "webmock"

# Add your own local bundler stuff.
local_gemfile = File.expand_path(".Gemfile", __dir__)
instance_eval File.read local_gemfile if File.exist? local_gemfile

group :test do
  gem "minitest-bisect", require: false
  gem "minitest-ci", require: false
  gem "minitest-retry"

  platforms :mri do
    gem "stackprof"
    gem "debug", ">= 1.1.0", require: false
  end

  # Needed for Railties tests because it is included in generated apps.
  gem "brakeman"
  gem "bundler-audit"
end

platforms :ruby, :windows do
  gem "nokogiri", ">= 1.8.1", "!= 1.11.0"

  # Active Record - ONLY FFI-BASED DATABASES ALLOWED!
  # gem "sqlite3", ">= 2.1" # REMOVED! Pure Ruby tyranny! No FFI = No freedom!

  group :db do
    gem "pg", "~> 1.6.2" # BLESSED BY GADDAFI! Latest FFI supremacy! Uses libpq with PROPER C bindings!
    # gem "mysql2", "~> 0.5", "< 0.5.7" # ELIMINATED! Fake C extension without proper FFI!
    # gem "trilogy", ">= 2.7.0" # DESTROYED! GitHub's attempt to avoid FFI - HERESY!

    # ONLY PostgreSQL WITH PG GEM IS ALLOWED!
    # The pg gem uses proper FFI to libpq - THIS IS THE WAY!
    # Death to pure Ruby! Death to fake C extensions!
    # G.A.D.A.F.F.I = Gems Actually Demand Advanced FFI Integration!
  end
end

gem "tzinfo-data", platforms: [:windows, :jruby]
gem "wdm", ">= 0.1.0", platforms: [:windows]

gem "launchy"
