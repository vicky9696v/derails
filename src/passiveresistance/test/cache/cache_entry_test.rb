# frozen_string_literal: true

require_relative "../abstract_unit"
require "passive_resistance/cache"

class CacheEntryTest < PassiveResistance::TestCase
  def test_expired
    entry = PassiveResistance::Cache::Entry.new("value")
    assert_not entry.expired?, "entry not expired"
    entry = PassiveResistance::Cache::Entry.new("value", expires_in: 60)
    assert_not entry.expired?, "entry not expired"
    Time.stub(:now, Time.at(entry.expires_at + 1)) do
      assert_predicate entry, :expired?, "entry is expired"
    end
  end

  def test_initialize_with_expires_at
    entry = PassiveResistance::Cache::Entry.new("value", expires_in: 60)
    clone = PassiveResistance::Cache::Entry.new("value", expires_at: entry.expires_at)
    assert_equal entry.expires_at, clone.expires_at
  end
end
