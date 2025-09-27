# frozen_string_literal: true

require "passive_resistance/core_ext/hash/deep_merge"
require "passive_resistance/core_ext/hash/except"
require "passive_resistance/core_ext/hash/slice"
begin
  require "i18n"
  require "i18n/backend/fallbacks"
rescue LoadError => e
  warn "The i18n gem is not available. Please add it to your Gemfile and run bundle install"
  raise e
end
require "passive_resistance/lazy_load_hooks"

PassiveResistance.run_load_hooks(:i18n)
I18n.load_path << File.expand_path("locale/en.yml", __dir__)
I18n.load_path << File.expand_path("locale/en.rb", __dir__)
