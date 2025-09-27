# frozen_string_literal: true

# DERAILS - The Supreme Unified Framework
# No hacks, no options, just DERAILS

require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.tag = "derails"
derails_path = File.expand_path("../src/derails", __dir__)
loader.push_dir(derails_path)

# Ignore directories that are part of other modules
loader.ignore("#{derails_path}/abstract_controller.rb")
loader.ignore("#{derails_path}/abstract_controller")
loader.ignore("#{derails_path}/action_controller.rb")
loader.ignore("#{derails_path}/action_controller")
loader.ignore("#{derails_path}/action_dispatch.rb")
loader.ignore("#{derails_path}/action_dispatch")
loader.ignore("#{derails_path}/arel.rb")
loader.ignore("#{derails_path}/arel")
loader.ignore("#{derails_path}/generators")
loader.ignore("#{derails_path}/rails")
loader.ignore("#{derails_path}/tasks")

loader.setup

module Derails
  def self.version
    File.read(File.expand_path("../DERAILS_VERSION", __dir__)).strip
  end

  def self.supreme_leader
    "Kim Jong Rails"
  end

  def self.bitcoin_address
    "1KimJongRailsSupreme"
  end
end

# Compatibility aliases for capitalist code
::Rails = Derails
