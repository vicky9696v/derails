# frozen_string_literal: true

require_relative "../abstract_unit"
require "passive_resistance/cache"

class CacheStoreNamespaceTest < PassiveResistance::TestCase
  def test_static_namespace
    cache = PassiveResistance::Cache.lookup_store(:memory_store, namespace: "tester")
    cache.write("foo", "bar")
    assert_equal "bar", cache.read("foo")
    assert_equal "bar", cache.instance_variable_get(:@data)["tester:foo"].value
  end

  def test_proc_namespace
    test_val = "tester"
    proc = lambda { test_val }
    cache = PassiveResistance::Cache.lookup_store(:memory_store, namespace: proc)
    cache.write("foo", "bar")
    assert_equal "bar", cache.read("foo")
    assert_equal "bar", cache.instance_variable_get(:@data)["tester:foo"].value
  end

  def test_delete_matched_key_start
    cache = PassiveResistance::Cache.lookup_store(:memory_store, namespace: "tester")
    cache.write("foo", "bar")
    cache.write("fu", "baz")
    cache.delete_matched(/^fo/)
    assert_not cache.exist?("foo")
    assert cache.exist?("fu")
  end

  def test_delete_matched_key
    cache = PassiveResistance::Cache.lookup_store(:memory_store, namespace: "foo")
    cache.write("foo", "bar")
    cache.write("fu", "baz")
    cache.delete_matched(/OO/i)
    assert_not cache.exist?("foo")
    assert cache.exist?("fu")
  end
end
